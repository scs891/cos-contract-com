// start up 的 setting 上链
pragma solidity >=0.4.21 <0.7.0;

contract IRO
{
    address private _owner;

    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }

    struct TokenSetting {
        string tokenName;
        string tokenSymbol;
        string tokenAddr;
        address[] walletAddrs;
    }

    struct VoteSetting {
        string voteType;
        string voteTokenLimit;
        address[] voteAssignAddrs;
        string voteMSupportPercent;
        string voteMinApprovalPercent;
        string voteMinDurationHours;
        string voteMaxDurationHours;
    }

    struct Setting {
        TokenSetting tokenSetting;
        VoteSetting voteSetting;
    }

    mapping (string => Setting) IROs;

    constructor()
        public {
        _owner = msg.sender;
    }

    function newSetting(string memory id,
                        string memory tokenName, string memory tokenSymbol, string memory tokenAddr,
                        address[] memory walletAddrs,
                        string memory voteType, string memory voteTokenLimit, address[] memory voteAssignAddrs,
                        string memory voteMSupportPercent, string memory voteMinApprovalPercent,
                        string memory voteMinDurationHours, string memory voteMaxDurationHours)
                        public
                        payable {
        TokenSetting memory tokenSetting = TokenSetting(tokenName, tokenSymbol, tokenAddr, walletAddrs);
        VoteSetting memory voteSetting = VoteSetting(voteType, voteTokenLimit,
                                                     voteAssignAddrs,voteMSupportPercent,voteMinApprovalPercent,
                                                     voteMinDurationHours, voteMaxDurationHours);
        IROs[id] = Setting(tokenSetting, voteSetting);
    }

    function getTokenSetting(string memory id)
        public
        view
        returns (string memory tokenName, string memory tokenSymbol, string memory tokenAddr,
                address[] memory walletAddrs){
        return (IROs[id].tokenSetting.tokenName, IROs[id].tokenSetting.tokenSymbol,
                IROs[id].tokenSetting.tokenAddr, IROs[id].tokenSetting.walletAddrs);
    }

    function getVoteSetting(string memory id)
        public
        view
        returns (string memory voteType, string memory voteTokenLimit, address[] memory voteAssignAddrs,
                 string memory voteMSupportPercent, string memory voteMinApprovalPercent,
                 string memory voteMinDurationHours, string memory voteMaxDurationHours){
        return (IROs[id].voteSetting.voteType, IROs[id].voteSetting.voteTokenLimit, IROs[id].voteSetting.voteAssignAddrs,
                IROs[id].voteSetting.voteMSupportPercent, IROs[id].voteSetting.voteMinApprovalPercent,
                IROs[id].voteSetting.voteMinDurationHours, IROs[id].voteSetting.voteMaxDurationHours);
    }
}
