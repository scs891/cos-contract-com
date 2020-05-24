pragma solidity >=0.4.21 <0.7.0;

contract Startup
{
    address private _owner;
    address payable private _coinbase;

    struct Profile {
        string name;
        string category;
        string misson;
        string desc;
    }

    mapping (string => Profile) startups;

    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }

    constructor()
        public {
        _owner = msg.sender;
    }

    function setCoinBase(address addr)
        isOwner
        public {
        _coinbase = addr;
    }

    function newStartup(string memory id, string memory name, string memory category, string memory misson, string memory desc) public payable {
        require(msg.value >= 1e17);
        require(_coinbase != address(0));
        Profile memory p = Profile(name, category, misson, desc);
        startups[id] = p;
        _coinbase.transfer(msg.value);
    }

    function getStartup(string memory id)
        public
        view
        returns (string memory name, string memory category, string memory misson, string memory desc){
        return (startups[id].name, startups[id].category, startups[id].misson, startups[id].desc);
    }
}