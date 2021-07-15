// start up  上链
pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;

contract Startup
{
    address private _owner;
    address payable private _coinbase;

    struct Profile {
        string id;
        string name;
        string categoryId;
        string mission;
        string descriptionAddr;
    }
    event createdStartup(string startupId, Profile startUp);

    mapping(string => Profile) startups;

    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }

    constructor()
    public {
        _owner = msg.sender;
    }

    function setCoinBase(address payable addr)
    isOwner
    public {
        _coinbase = addr;
    }

    /*
    * tuple param, as (id, name, categoryId...)
    */
    function newStartup(Profile memory p) public payable {
        require(msg.value >= 1e17);
        require(_coinbase != address(0));
        require(bytes(p.id).length != 0);
        startups[p.id] = p;
        _coinbase.transfer(msg.value);
        emit createdStartup(p.id, p);
    }

    function getStartup(string calldata id)
    external
    view
    returns (string memory name, string memory categoryId, string memory mission, string memory descriptionAddr){
        return (startups[id].name, startups[id].categoryId, startups[id].mission, startups[id].descriptionAddr);
    }
}
