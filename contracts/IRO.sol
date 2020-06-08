pragma solidity >=0.4.21 <0.7.0;

contract IRO
{
    address private _owner;

    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }

    struct WalletAddr{
        string name;
        address addr;
    }

    struct IRO {
        string tokenName;
        string tokenSymbol;
        string tokenAddr;
        WalletAddr[] walletAddrs;
        string voteType;
        string voteTokenLimit;
        address[] voteAssignAddrs;
        string voteMSupportPercent;
        string voteMinApprovalPercent;
        string voteMinDurationHours;
        string voteMaxDurationHours;
    }
    
    mapping (string => IRO) IROs;

    constructor()
        public {
        _owner = msg.sender;
    }
}