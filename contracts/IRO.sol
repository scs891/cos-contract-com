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
        None,
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
        uint256 voteMinSupporters;
        string voteMinApprovalPercent;
        string voteMinDurationHours;
        string voteMaxDurationHours;
    }

    struct Setting {
        string id;
        TokenSetting tokenSetting;
        ProposerSetting proposerSetting;
        VoterSetting voterSetting;
    }

    mapping(string => Setting) IROs;

    constructor()
    public {
        _owner = msg.sender;
    }

    event sendWhenHasChanges(string indexed id, Setting setting);

    // function newSetting(string memory id,
    //     string memory tokenName, string memory tokenSymbol, string memory tokenAddr,
    //     address[] memory walletAddrs,
    //     string memory voteType, string memory voteTokenLimit, address[] memory voteAssignAddrs,
    //     string memory voteMSupportPercent, string memory voteMinApprovalPercent,
    //     string memory voteMinDurationHours, string memory voteMaxDurationHours)
    // public {
    //     TokenSetting memory tokenSetting = TokenSetting(tokenName, tokenSymbol, tokenAddr, walletAddrs);
    //     VoterSetting memory voterSetting = VoterSetting(voteType, voteTokenLimit,voteAssignAddrs, voteMSupportPercent, voteMinApprovalPercent, voteMinDurationHours, voteMaxDurationHours);
    //     ProposerSetting memory proposerSetting = ProposerSetting(ProposerDriver.None,0,new address[](0));
    //     Setting memory setting = Setting(id, tokenSetting, proposerSetting, voterSetting);
    // }

    function fullSet(Setting memory setting) public isOwner {
        require(bytes(setting.id).length != 0, 'setting is empty, please check inputs.');
        IROs[setting.id] = setting;
        emit sendWhenHasChanges(setting.id, setting);
    }

    function partialSet(Setting memory setting) public isOwner {
        require(bytes(setting.id).length != 0, 'setting is empty, please check inputs.');
        Setting memory originSetting = IROs[setting.id];
        if (bytes(originSetting.id).length != 0) {
            originSetting = setting;
        }

        bool hasChanges = false;
        if (bytes(setting.tokenSetting.tokenName).length != 0) {
            originSetting.tokenSetting = setting.tokenSetting;
            hasChanges = true;
        }

        if (setting.proposerSetting.driver != ProposerDriver.None) {
            originSetting.proposerSetting = setting.proposerSetting;
            hasChanges = true;
        }

        if (bytes(setting.voterSetting.voteType).length != 0) {
            originSetting.voterSetting = setting.voterSetting;
            hasChanges = true;
        }

        if (hasChanges) {
            IROs[setting.id] = originSetting;
            emit sendWhenHasChanges(setting.id, originSetting);
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
        uint256 voteMinSupporters, string memory voteMinApprovalPercent,
        string memory voteMinDurationHours, string memory voteMaxDurationHours){
        return (IROs[id].voterSetting.voteType, IROs[id].voterSetting.voteTokenLimit, IROs[id].voterSetting.voteAssignAddrs,
        IROs[id].voterSetting.voteMinSupporters, IROs[id].voterSetting.voteMinApprovalPercent,
        IROs[id].voterSetting.voteMinDurationHours, IROs[id].voterSetting.voteMaxDurationHours);
    }

    function setting(string calldata id) external view returns (Setting memory) {
        require(bytes(id).length != 0, "id is empty!");
        return IROs[id];
    }
}
