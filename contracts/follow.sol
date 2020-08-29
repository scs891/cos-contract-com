// hunter 承接 bounty 的时候， 需要给 bounty 的合约账户转10个token

pragma solidity >=0.4.21 <0.7.0;

contract Follow {
    address private _owner;
    address payable private _coinbase;

    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }

    constructor() public {
        _owner = msg.sender;
    }

    function setCoinBase(address payable addr) isOwner public {
        _coinbase = addr;
    }

    function followBounty() public payable {
        require(msg.value > 10e18);
        require(_coinbase != address(0) );
        _coinbase.transfer(msg.value);
    }
}
