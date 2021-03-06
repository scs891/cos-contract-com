pragma solidity ^0.5.6;
interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;

    function approve(address guy, uint wad) external returns (bool);

    function transferFrom(address src, address dst, uint wad) external returns (bool);
}