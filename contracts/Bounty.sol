pragma solidity >=0.4.21 <0.7.0;

contract Bounty {
  // 我的钱包地址
  address private _owner;
  // 收款地址
  address payable private _conbase;

// 声明bounty的结构体 
struct Profile {
    string startupName;
    string title;
    string intro;
    string payment;
  }
  
  // 一个id对应一个bounty
  mapping (string => Profile) bounty;

  modifier isOnwer() {
    require(msg.sender === _owner);
    _
  }

  constructor() public {
    _owner = msg.sender;
  }

  function setConbise(address payable addr) isOnwer public {
    _conbase = addr;
  }

  // bounty 上链
  function newBounty(
    string memory id, 
    string memory startupName, 
    string memory title,
    string memory intro,
    string memory payment
  ) {
      require(msg.value >= 1e17);
      require(_conbase != address(0));
      Profile p = Profile(startupName, title, intro, payment);
      bounty[id] = p;
      _conbase.transfer(msg.value);

  }

  // 根据id返回当前上链的bounty内容
  function getBounty(string memory id) public view returns (
    string memory startupName, 
    string memory title,
    string memory intro,
    string memory payment
  ) {
    return (
      bounty[id].name,
      bounty[id].title,
      bounty[id].intro,
      bounty[id].payment,
    )
  }
}
