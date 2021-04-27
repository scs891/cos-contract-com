pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;

import "./interfaces/IErc20.sol";
import "./IRO.sol";
import "./Disco.sol";
import "./common/Base.sol";
import "./common/FundPool.sol";

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
    }

    struct Payment {
        address payer;
        PaymentMode mode;
        uint256 totalMonths;
        string date;     //require text! Good luck for any external caller or user.
        PaymentDetail[] details;
        IERC20 token;
        uint256 totalAmount;
        FundPool pool;
    }

    struct PaymentDetail {
        uint256 token;
        string terms;
    }

    struct ProposerSetup {
        IRO.ProposerDriver driver;
    }

    struct VoterSetup {
        string voteMSupportPercent;
        string voteMinApprovalPercent;
        string voteMinDurationHours;
        string voteMaxDurationHours;
    }

    mapping(string => mapping(string => ProposalDetail)) private discoProposals;

    event accepted(ProposalDetail proposal);

    function accept(ProposalDetail memory proposal) payable returns (ProposalDetail memory) {
        assert(bytes(proposal.serialId).length != 0, "proposal serialId is empty!");
        assert(bytes(proposal.discoId).length != 0, "proposal discoId is empty!");

        IRO.Setting baseSetting = _iroBase.setting(proposal.discoId);
        assert(address(baseSetting) != address(0), "base setting not exists.");

        IRO.ProposerSetting proposerSetting = baseSetting.proposerSetting;
        assert(address(proposerSetting) != address(0), "proposer setting not exists.");
        proposal.proposerSetup = ProposerSetup(proposerSetting.driver);

        IRO.VoterSetting voterSetting = baseSetting.voterSetting;
        assert(address(voterSetting) != address(0), "voter setting not exists.");
        proposal.voteSetup = VoterSetup(voterSetting.ProposerSetup(voteMSupportPercent, voteMinApprovalPercent, voteMinDurationHours, voteMaxDurationHours));

        //lock init proposal token into a pool.
        IERC20 token = _discoBase.discoToken(proposal.discoId);
        proposal.payment.token = token;
        //cal poolId
        string memory poolId = string(abi.encodePacked(proposal.discoId, "@", proposal.serialId));
        proposal.payment.pool = FundPool(poolId);
        token.transferFrom(msg.sender, proposal.payment.pool.getAddress(), proposal.payment.totalAmount);

        mapping(string => ProposalDetail) memory discoProposalMapper = discoProposals[proposal.discoId];
        discoProposalMapper[proposal.serialId] = proposal;
        discoProposals[proposal.discoId] = discoProposalMapper;
        emit accepted(proposal);

        return proposal;
    }

    function proposalDetail(string calldata id, string calldata serialId) external view returns (ProposalDetail memory){
        return internalProposal(id, serialId);
    }

    function internalDiscoProposalDetail(string calldata id) internal view returns (mapping(string => ProposalDetail) memory){
        assert(bytes(id).length != 0, "disco id is empty!");
        mapping(string => ProposalDetail) memory discoProposalMapper = discoProposals[proposal.discoId];
        // inappropriate when too much.
        return discoProposalMapper[serialId];
    }

    /**
     * get proposal count.
     **/
    function discoProposalCount(string calldata id) external view returns (uint){
        return internalDiscoProposalDetail(id).length;
    }

    /**
    * decide proposal status.
    **/
    function decide(string calldata id, string calldata serialId, ProposalStatus status){
        ProposalDetail memory proposal = internalProposal(id, serialId);
        assert(address(proposal) != address(0), "proposal missing.");
        if (status != proposal.status) {
            proposal.status = status;
            discoProposalMapper[serialId] = proposal;
        }
        // notify to listener for status.
        emit accepted(proposal);
    }

    /**
    * get proposal status.
    **/
    function proposalStatus(string calldata id, string calldata serialId, ProposalStatus status) returns (ProposalStatus memory){
        ProposalDetail memory proposal = internalProposal(id, serialId);
        assert(address(proposal) != address(0), "proposal missing.");
        return proposal.status;
    }

    function internalProposal(string calldata id, string calldata serialId) internal view returns (ProposalDetail memory){
        assert(bytes(id).length != 0, "disco id is empty!");
        assert(bytes(serialId).length != 0, "proposal serialId is empty!");
        mapping(string => ProposalDetail) memory discoProposalMapper = discoProposals[proposal.discoId];
        mapping(string => ProposalDetail) memory discoProposalMapper = discoProposals[proposal.discoId];
        ProposalDetail memory proposal = discoProposalMapper[serialId];
        return proposal;
    }

    //owner manage.
    function forceSet(ProposalDetail memory proposal) isOwner returns (ProposalDetail memory) {
        assert(bytes(proposal.serialId).length != 0, "proposal serialId is empty!");
        assert(bytes(proposal.discoId).length != 0, "proposal discoId is empty!");
        mapping(string => ProposalDetail) memory discoProposalMapper = discoProposals[proposal.discoId];
        discoProposalMapper[proposal.serialId] = proposal;
        discoProposals[proposal.discoId] = discoProposalMapper;
        emit accepted(proposal);
        return proposal;
    }


    function setIROBase(address _iroAddress) isOwner {
        assert(_iroAddress != address(0), "iro address is empty.");
        _iroBase = IRO(_iroAddress);
    }

    function setDiscoBase(address _discoAddress) isOwner {
        assert(_discoAddress != address(0), "disco address is empty.");
        _discoBase = Disco(_discoAddress);
    }
}