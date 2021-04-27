// start up 的 setting 上链
pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;

contract IRO
{
    address private _owner;

    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }

    enum ProposerDriver{
        Founder_Assign,
        POS,
        All
    }

    struct TokenSetting {
        string tokenName;
        string tokenSymbol;
        string tokenAddr;
        address[] walletAddrs;
    }

    struct ProposerSetting {
        ProposerDriver driver;
        uint256 tokenBalance;
        address[] assignAddresses;
    }

    struct VoterSetting {
        string voteType;
        string voteTokenLimit;
        address[] voteAssignAddrs;
        string voteMSupportPercent;
        string voteMinApprovalPercent;
        string voteMinDurationHours;
        string voteMaxDurationHours;
    }

    struct Setting {
        string id;
        TokenSetting tokenSetting;
        ProposerSetting proposerSetting;
        VoterSetting voteSetting;
    }

    mapping(string => Setting) IROs;

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
    public {
        TokenSetting memory tokenSetting = TokenSetting(tokenName, tokenSymbol, tokenAddr, walletAddrs);
        VoterSetting memory voteSetting = VoterSetting(voteType, voteTokenLimit,
            voteAssignAddrs, voteMSupportPercent, voteMinApprovalPercent,
            voteMinDurationHours, voteMaxDurationHours);
        IROs[id] = Setting(tokenSetting, voteSetting);
    }

    function fullSet(Setting memory setting) public isOwner {
        assert(address(setting) != 0, 'setting is empty.');
        assert(bytes(setting.id).length != 0, 'need id.');
        IROs[setting.id] = setting;
    }

    function partialSet(Setting memory setting) public isOwner {
        assert(address(setting) != 0, 'setting is empty.');
        assert(bytes(setting.id).length != 0, 'need id.');
        Setting memory originSetting = IROs[setting.id];
        if (address(originSetting) == address(0)) {
            originSetting = setting;
        }

        bool hasChanges = false;
        if (address(setting.tokenSetting) != address(0)) {
            originSetting.tokenSetting = setting.tokenSetting;
            hasChanges = true;
        }

        if (address(setting.proposerSetting) != address(0)) {
            originSetting.proposerSetting = setting.proposerSetting;
            hasChanges = true;
        }

        if (address(setting.voteSetting) != address(0)) {
            originSetting.voteSetting = setting.voteSetting;
            hasChanges = true;
        }

        if (hasChanges) {
            IROs[setting.id] = originSetting;
        }
    }

    function getTokenSetting(string memory id)
    public
    view
    returns (string memory tokenName, string memory tokenSymbol, string memory tokenAddr,
        address[] memory walletAddrs){
        return (IROs[id].tokenSetting.tokenName, IROs[id].tokenSetting.tokenSymbol,
        IROs[id].tokenSetting.tokenAddr, IROs[id].tokenSetting.walletAddrs);
    }

    function getVoterSetting(string memory id)
    public
    view
    returns (string memory voteType, string memory voteTokenLimit, address[] memory voteAssignAddrs,
        string memory voteMSupportPercent, string memory voteMinApprovalPercent,
        string memory voteMinDurationHours, string memory voteMaxDurationHours){
        return (IROs[id].voteSetting.voteType, IROs[id].voteSetting.voteTokenLimit, IROs[id].voteSetting.voteAssignAddrs,
        IROs[id].voteSetting.voteMSupportPercent, IROs[id].voteSetting.voteMinApprovalPercent,
        IROs[id].voteSetting.voteMinDurationHours, IROs[id].voteSetting.voteMaxDurationHours);
    }

    function setting(string memory id) external view returns (Setting memory) {
        assert(bytes(id).length != 0, "id is empty!");
        return IROs[id];
    }
}
