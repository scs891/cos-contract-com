pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;

import "./interfaces/IErc20.sol";
import "./Base.sol";
import "./IRO.sol";

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

    constructor() Base() public {}

    struct ProposalDetail {
        string discoId;
        string serialId;
        string title;
        ProposalStatus status;
        ProposalMode mode;
        string contact;
        string description;
        Payment[] payments;
        ProposerSetup proposerSetup;
        VoterSetup voteSetup;
    }

    struct Payment {
        address payer;
        PaymentMode mode;
        uint256 totalMonths;
        string date;     //require text! Good luck for any external caller or user.
        PaymentDetail[] details;
        uint256 totalAmount;
    }

    struct PaymentDetail {
        uint256 token;
        string terms;
    }

    struct ProposerSetup {
        ProposerDriver driver;
    }

    struct VoterSetup {
        string voteMSupportPercent;
        string voteMinApprovalPercent;
        string voteMinDurationHours;
        string voteMaxDurationHours;
    }

    mapping(string => mapping(string => ProposalDetail)) private discoProposals;

    event accepted(ProposalDetail proposal);

    function accept(ProposalDetail memory proposal) returns (ProposalDetail memory){
        assert(bytes(proposal.serialId).length != 0, "proposal serialId is empty!");
        assert(bytes(proposal.discoId).length != 0, "proposal discoId is empty!");

        Setting baseSetting = _iroBase.setting(proposal.discoId);
        assert(address(baseSetting) != address(0), "base setting not exists.");

        ProposerSetting proposerSetting = baseSetting.proposerSetting;
        assert(address(proposerSetting) != address(0), "proposer setting not exists.");
        proposal.proposerSetup = ProposerSetup(proposerSetting.driver);

        VoterSetting voterSetting = baseSetting.voterSetting;
        assert(address(voterSetting) != address(0), "voter setting not exists.");
        proposal.voteSetup = VoterSetup(voterSetting.ProposerSetup(voteMSupportPercent, voteMinApprovalPercent, voteMinDurationHours, voteMaxDurationHours));

        mapping(string => ProposalDetail) memory discoProposalMapper = discoProposals[proposal.discoId];
        discoProposalMapper[proposal.serialId] = proposal;
        discoProposals[proposal.discoId] = discoProposalMapper;
        emit accepted(proposal);
        return proposal;
    }

    function proposalDetail(string calldata id, string calldata serialId) external view returns (ProposalDetail memory){
        assert(bytes(id).length != 0, "disco id is empty!");
        assert(bytes(serialId).length != 0, "proposal serialId is empty!");
        mapping(string => ProposalDetail) memory discoProposalMapper = discoProposals[proposal.discoId];
        return discoProposalMapper[serialId];
    }

    function discoProposalDetail(string calldata id) external view returns (mapping(string => ProposalDetail) memory){
        assert(bytes(id).length != 0, "disco id is empty!");
        mapping(string => ProposalDetail) memory discoProposalMapper = discoProposals[proposal.discoId];
        // inappropriate when too much.
        return discoProposalMapper[serialId];
    }

    /**
    * decide proposal status.
    **/
    function decide(string calldata id, string calldata serialId, ProposalStatus status){
        assert(bytes(id).length != 0, "disco id is empty!");
        assert(bytes(serialId).length != 0, "proposal serialId is empty!");
        mapping(string => ProposalDetail) memory discoProposalMapper = discoProposals[proposal.discoId];
        mapping(string => ProposalDetail) memory discoProposalMapper = discoProposals[proposal.discoId];
        ProposalDetail memory proposal = discoProposalMapper[serialId];
        assert(address(proposal) != address(0), "proposal missing.");
        if (status != proposal.status) {
            proposal.status = status;
            discoProposalMapper[serialId] = proposal;
        }
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

}
