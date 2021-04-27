// start up  上链
pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;

import "./interfaces/IErc20.sol";
import "./IRO.sol";

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
