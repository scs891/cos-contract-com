pragma solidity >=0.4.21 <0.7.0;

contract Startup
{
    struct Profile {
        string name;
        string category;
        string misson;
        string desc;
    }

    mapping (string => Profile) startups;

    function newStartup(string memory id, string memory name, string memory category, string memory misson, string memory desc) public payable {
        Profile memory p = Profile(name, category, misson, desc);
        startups[id] = p;
    }

    function getStartup(string memory id)
        public
        view
        returns (string memory name, string memory category, string memory misson, string memory desc){
        return (startups[id].name, startups[id].category, startups[id].misson, startups[id].desc);
    }
}