pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;

import "../interfaces/IErc20.sol";
/**
* like uniswap pair.
* owner original call(skip person auth).
* [issue] mechanism optimization and improvement.
**/
contract FundPool
{
    string private _id;

    // suppose the deployed contract has a purpose

    //0.6.x
    //receive() external payable {}
    function() external payable {}

    constructor(string memory id) public {
        _id = id;
    }

    function getDiscoId() public view returns (string memory) {
        return _id;
    }

    function ethTransfer(address payable to, uint256 amount) external payable {
        to.transfer(amount);
    }

    function approve(IERC20 token, address to, uint256 amount) external {
        require(token.approve(to, amount));
    }

    function transfer(IERC20 token, address to, uint256 amount) external {
        require(token.transfer(to, amount));
    }

    function getAddress() public view returns (address payable) {
        return address(uint160(address(this)));
    }
}
