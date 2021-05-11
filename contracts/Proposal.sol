pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;


import "./IRO.sol";
import "./Disco.sol";
import "./common/Base.sol";
import "./common/FundPool.sol";
import "./interfaces/IErc20.sol";
import {NumUtils} from "./libraries/NumUtils.sol";

contract Proposal is Base
{

    IRO private _iroBase;

    Disco private _discoBase;

    enum ProposalStatus{
        Voting, Pass, Defeated, Invalid
    }

    enum ProposalMode{
        Finance, Governance, Strategy, Product, Media, Community, Node
    }

    enum PaymentMode{
        MonthlyPay, OneTimePay
    }

    constructor(address _iroAddress, address _discoAddress) Base() public {
        setIROBase(_iroAddress);
        setDiscoBase(_discoAddress);
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
    }

    struct Payment {
        address payer;
        PaymentMode mode;
        uint256 totalMonths;
        string date;     //require text! Good luck for any external caller or user.
        IERC20 token;
        uint256 totalAmount;
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
        string voteMSupportPercent;
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

    event accepted(ProposalDetail indexed proposal, PaymentDetail[] indexed paymentDetails);

    event statusChanged(string indexed id, ProposalStatus indexed original, ProposalStatus indexed target);

    event voted(Vote indexed v);

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
        require(bytes(voterSetting.voteType).length != 0, "voter setting not exists.");

        uint256 bt = block.timestamp;
        uint256 voteDurationHours;
        if (proposal.voteSetup.voteDurationHours == 0) {
            //string to uint
            voteDurationHours = NumUtils.stringToUint(voterSetting.voteMinDurationHours);
        } else {
            voteDurationHours = proposal.voteSetup.voteDurationHours;
        }

        proposal.voteSetup = VoterSetup(voterSetting.voteMSupportPercent, voterSetting.voteMinApprovalPercent, voteDurationHours, bt + voteDurationHours * 3600);

        //lock init proposal token into a pool.
        IERC20 token = _discoBase.discoToken(proposal.discoId);
        proposal.payment.token = token;
        //cal poolId
        string memory poolId = getPoolId(proposal);
        proposal.payment.pool = new FundPool(poolId);
        if (proposal.payment.totalAmount > 0) {
            token.transferFrom(msg.sender, proposal.payment.pool.getAddress(), proposal.payment.totalAmount);
        }

        uint256 paymentDetailsSize = paymentDetails.length;
        for (uint256 i = 0; i < paymentDetailsSize; i++) {
            proposalPaymentDetails[poolId].push(paymentDetails[i]);
        }
        //record block once
        proposal.blockTime = bt;
        discoProposalMapper[proposal.serialId] = proposal;
        countDiscoProposals[proposal.discoId]++;
        emit accepted(proposal, paymentDetails);
        return proposal;
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
        IERC20 token = _discoBase.discoToken(proposal.discoId);
        token.transferFrom(msg.sender, proposal.payment.pool.getAddress(), v.pos + v.neg);
        v.voteBt = block.timestamp;
        v.voter = msg.sender;
        string memory poolId = getPoolId(v.discoId, v.serialId);
        votes[poolId].push(v);
        emit voted(v);
    }

    /**
  * release pool vote token when proposal is not Voting.
  * release pool payment token when proposal is not Pass.
  **/
    function releaseProposal(string calldata discoId, string calldata serialId) external isOwner {
        ProposalDetail memory proposal = internalProposal(discoId, serialId);
        require(bytes(discoId).length != 0, "proposal missing, check first.");
        require(proposal.status != ProposalStatus.Voting, "the proposal could not be released.");
        IERC20 token = _discoBase.discoToken(proposal.discoId);
        string memory poolId = getPoolId(discoId, serialId);
        Vote[] memory vs = votes[poolId];
        FundPool pool = proposal.payment.pool;
        for (uint256 i = 0; i < vs.length; i++) {
            Vote memory v = vs[i];
            pool.transfer(token, v.voter, v.pos + v.neg);
        }
        if (proposal.status != ProposalStatus.Pass) {
            pool.transfer(token, proposal.payment.payer, proposal.payment.totalAmount);
        }
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
        emit accepted(proposal, paymentDetails);
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

    function setDiscoBase(address _discoAddress) public isOwner {
        require(_discoAddress != address(0), "disco address is empty.");
        _discoBase = Disco(_discoAddress);
    }
}