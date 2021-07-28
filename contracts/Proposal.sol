pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;


import "./IRO.sol";
import "./common/Base.sol";
import "./common/FundPool.sol";
import "./interfaces/IErc20.sol";
import {NumUtils} from "./libraries/NumUtils.sol";

contract Proposal is Base
{

    IRO private _iroBase;

    enum ProposalStatus{
        Voting, Pass, Defeated, Invalid
    }

    enum ProposalMode{
        Finance, Governance, Strategy, Product, Media, Community, Node
    }

    enum PaymentMode{
        MonthlyPay, OneTimePay
    }

    constructor(address _iroAddress) Base() public {
        setIROBase(_iroAddress);
    }

    struct ProposalDetail {
        string discoId;
        string serialId;
        string title;
        ProposalStatus status;
        ProposalMode mode;
        string contact;
        string description;
        Payment payment;
        ProposerSetup proposerSetup;
        VoterSetup voteSetup;
        uint256 blockTime;
        address proposer;
    }

    struct Payment {
        address payer;
        PaymentMode mode;
        uint256 totalMonths;
        string date;     //require text! Good luck for any external caller or user.
        uint256 paymentAmount;
        uint256 totalAmount;
        IERC20 token;
        FundPool pool;
    }

    struct PaymentDetail {
        uint256 index;
        uint256 token;
        string terms;
    }

    struct ProposerSetup {
        IRO.ProposerDriver driver;
    }

    struct VoterSetup {
        uint256 voteMinSupporters;
        string voteMinApprovalPercent;
        uint256 voteDurationHours;
        uint256 voteEndTime;
    }

    struct Vote {
        string discoId;
        string serialId;
        address voter;
        uint256 pos;
        uint256 neg;
        uint256 voteBt;
    }

    mapping(string => mapping(string => ProposalDetail)) private discoProposals;
    //unsupported copy struct memory xxx[] to xxx, so create mapping to save the payment details.
    mapping(string => PaymentDetail[]) private proposalPaymentDetails;
    mapping(string => uint256) private countDiscoProposals;
    mapping(string => Vote[]) private votes;

    event accepted(string indexed id, ProposalDetail proposal, PaymentDetail[] paymentDetails);

    event statusChanged(string indexed id, ProposalStatus original, ProposalStatus target);

    event voted(string indexed id, Vote v);

    function accept(ProposalDetail memory proposal, PaymentDetail[] memory paymentDetails) public payable returns (ProposalDetail memory) {
        require(bytes(proposal.serialId).length != 0, "proposal serialId is empty!");
        require(bytes(proposal.discoId).length != 0, "proposal discoId is empty!");
        mapping(string => ProposalDetail) storage discoProposalMapper = discoProposals[proposal.discoId];
        ProposalDetail memory checkProposal = discoProposalMapper[proposal.serialId];
        require(bytes(checkProposal.discoId).length == 0, "proposal already exists, please replace with the contract owner");

        IRO.Setting memory baseSetting = _iroBase.setting(proposal.discoId);
        require(bytes(baseSetting.id).length != 0, "base setting not exists.");

        IRO.ProposerSetting memory proposerSetting = baseSetting.proposerSetting;
        require(proposerSetting.driver != IRO.ProposerDriver.None, "proposer setting not exists.");
        proposal.proposerSetup = ProposerSetup(proposerSetting.driver);

        IRO.VoterSetting memory voterSetting = baseSetting.voterSetting;
        require(voterSetting.voteType != IRO.VoteType.None, "voter setting not exists.");

        uint256 bt = block.timestamp;
        uint256 voteDurationHours;
        if (proposal.voteSetup.voteDurationHours == 0) {
            //string to uint
            voteDurationHours = NumUtils.stringToUint(voterSetting.voteMinDurationHours);
        } else {
            voteDurationHours = proposal.voteSetup.voteDurationHours;
        }

        proposal.voteSetup = VoterSetup(voterSetting.voteMinSupporters, voterSetting.voteMinApprovalPercent, voteDurationHours, bt + voteDurationHours * 3600);

        //lock init proposal token into a pool.
        IERC20 token = IERC20(parseAddr(baseSetting.tokenSetting.tokenAddr));
        proposal.payment.token = token;
        //cal poolId
        string memory poolId = getPoolId(proposal);
        proposal.payment.pool = new FundPool(poolId);
        //        disable lock payment token in pool.
        //        proposal.payment.payer = msg.sender;
        //        if (proposal.payment.totalAmount > 0) {
        //            token.transferFrom(msg.sender, proposal.payment.pool.getAddress(), proposal.payment.totalAmount);
        //        }

        uint256 paymentDetailsSize = paymentDetails.length;
        for (uint256 i = 0; i < paymentDetailsSize; i++) {
            proposalPaymentDetails[poolId].push(paymentDetails[i]);
        }

        //record block once
        if (proposal.proposer == address(0)) {
            proposal.proposer = msg.sender;
        }
        proposal.blockTime = bt;
        discoProposalMapper[proposal.serialId] = proposal;
        countDiscoProposals[proposal.discoId]++;
        emit accepted(proposal.serialId, proposal, paymentDetails);
        return proposal;
    }

    function parseAddr(string memory _a) internal pure returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

    function proposalDetail(string calldata id, string calldata serialId) external view returns (ProposalDetail memory, PaymentDetail[] memory paymentDetails){
        ProposalDetail memory proposal = internalProposal(id, serialId);
        string memory poolId = getPoolId(proposal);
        return (proposal, proposalPaymentDetails[poolId]);
    }

    function internalDiscoProposalDetail(string memory id) internal view returns (mapping(string => ProposalDetail) storage){
        require(bytes(id).length != 0, "disco id is empty!");
        mapping(string => ProposalDetail) storage discoProposalMapper = discoProposals[id];
        // inappropriate when too much.
        return discoProposalMapper;
    }

    /**
     * get proposal count.
     **/
    function discoProposalCount(string calldata id) external view returns (uint256){
        return countDiscoProposals[id];
    }

    /**
    * decide proposal status.
    **/
    function decide(string calldata id, string calldata serialId, ProposalStatus target) external {
        ProposalDetail memory proposal = internalProposal(id, serialId);
        require(bytes(proposal.discoId).length != 0, "proposal missing.");
        if (target != proposal.status) {
            ProposalStatus original = proposal.status;
            proposal.status = target;
            mapping(string => ProposalDetail) storage discoProposalMapper = discoProposals[proposal.discoId];
            discoProposalMapper[serialId] = proposal;
            // notify to listener for status.
            emit statusChanged(id, original, target);
        }

    }

    /**
    * get proposal status.
    **/
    function proposalStatus(string calldata id, string calldata serialId) external view returns (ProposalStatus){
        ProposalDetail memory proposal = internalProposal(id, serialId);
        require(bytes(proposal.discoId).length != 0, "proposal missing, check first.");
        return proposal.status;
    }

    function internalProposal(string memory id, string memory serialId) internal view returns (ProposalDetail memory){
        require(bytes(id).length != 0, "disco id is empty!");
        require(bytes(serialId).length != 0, "proposal serialId is empty!");
        mapping(string => ProposalDetail) storage discoProposalMapper = discoProposals[id];
        ProposalDetail memory proposal = discoProposalMapper[serialId];
        return proposal;
    }

    /**
    * vote when proposal is voting.
    * lock into the fundPool.
    **/
    function doVote(Vote memory v) public payable {
        ProposalDetail memory proposal = internalProposal(v.discoId, v.serialId);
        require(bytes(v.discoId).length != 0, "proposal missing, check first.");
        require(proposal.status == ProposalStatus.Voting, "the proposal could not be voted when status is not voting.");
        VoterSetup memory setup = proposal.voteSetup;
        uint256 bt = block.timestamp;
        require(bt <= setup.voteEndTime, "vote is expired.");
        require(v.pos + v.neg > 0, "a invalid vote, vote num <= 0.");
        IRO.Setting memory baseSetting = _iroBase.setting(proposal.discoId);
        IERC20 token = proposal.payment.token;
        token.transferFrom(msg.sender, proposal.payment.pool.getAddress(), v.pos + v.neg);
        v.voteBt = block.timestamp;
        v.voter = msg.sender;
        string memory poolId = getPoolId(v.discoId, v.serialId);
        votes[poolId].push(v);
        emit voted(proposal.serialId, v);
    }

    /**
    * release pool vote token when proposal is not Voting.
    * release pool payment token when proposal is not Pass.
    **/
    function releaseProposal(string calldata discoId, string calldata serialId) external isOwner {
        ProposalDetail memory proposal = internalProposal(discoId, serialId);
        require(bytes(discoId).length != 0, "proposal missing, check first.");
        require(proposal.status != ProposalStatus.Voting, "the proposal could not be released.");
        IRO.Setting memory baseSetting = _iroBase.setting(proposal.discoId);
        IERC20 token = proposal.payment.token;
        string memory poolId = getPoolId(discoId, serialId);
        Vote[] memory vs = votes[poolId];
        FundPool pool = proposal.payment.pool;
        for (uint256 i = 0; i < vs.length; i++) {
            Vote memory v = vs[i];
            pool.transfer(token, v.voter, v.pos + v.neg);
        }
        //        disable lock payment token in pool.
        //        if (proposal.status != ProposalStatus.Pass) {
        //            pool.transfer(token, proposal.payment.payer, proposal.payment.totalAmount);
        //        }
    }

    //owner manage.
    function fullSet(ProposalDetail memory proposal, PaymentDetail[] memory paymentDetails) public isOwner returns (ProposalDetail memory) {
        require(bytes(proposal.serialId).length != 0, "proposal serialId is empty!");
        require(bytes(proposal.discoId).length != 0, "proposal discoId is empty!");
        mapping(string => ProposalDetail) storage discoProposalMapper = discoProposals[proposal.discoId];
        discoProposalMapper[proposal.serialId] = proposal;
        string memory poolId = getPoolId(proposal);
        uint256 paymentDetailsSize = paymentDetails.length;
        for (uint256 i = 0; i < paymentDetailsSize; i++) {
            proposalPaymentDetails[poolId].push(paymentDetails[i]);
        }
        emit accepted(proposal.serialId, proposal, paymentDetails);
        return proposal;
    }

    //internal utils
    function getPoolId(string memory discoId, string memory serialId) internal pure returns (string memory){
        return string(abi.encodePacked(discoId, "@", serialId));
    }

    function getPoolId(ProposalDetail memory proposal) internal pure returns (string memory){
        return getPoolId(proposal.discoId, proposal.serialId);
    }

    function setIROBase(address _iroAddress) public isOwner {
        require(_iroAddress != address(0), "iro address is empty.");
        _iroBase = IRO(_iroAddress);
    }
}