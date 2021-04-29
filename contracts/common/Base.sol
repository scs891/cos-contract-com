pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;

contract Base
{
    address private _owner;

    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }

    constructor()
    public
    {
        _owner = msg.sender;
    }

}
