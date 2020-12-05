// Disco 上链
pragma solidity >=0.4.21 <0.7.0;


contract Disco {
  addrsss private _owner;

    struct Disco {
    address walletAddr;
    address tokenContract;
    string description;
    string fundRaisingTimeFrom;
    string fundRaisingTimeTo;
    uint256 investmentReward;
    uint256 rewardDeclineRate;
    uint256 shareToken;
    uint256 minFundRaising;
    uint256 addLiquidityPool;
    uint256 totalDepositToken;
  }

  mapping (string => Disco) discos;

  modifier isOwner() {
    require(msg.sender == _owner);
    _;
  }

  constructor()
    public {
        _owner = msg.sender;
  }

  function setCoinBase(address payable addr) isOwner public {
    _coinbase = addr;
  }
  

  // 创建Disco
  function newDisco(
    string memory id,
    address walletAddr;
    address tokenContract;
    string description;
    string fundRaisingTimeFrom;
    string fundRaisingTimeTo;
    uint256 investmentReward;
    uint256 rewardDeclineRate;
    uint256 shareToken;
    uint256 minFundRaising;
    uint256 addLiquidityPool;
    uint256 totalDepositToken;
  ) {
    Disco memory d = Disco(
      walletAddr,
      tokenContract,
      description,
      fundRaisingTimeFrom,
      fundRaisingTimeTo,
      investmentReward,
      rewardDeclineRate,
      shareToken,
      minFundRaising,
      addLiquidityPool,
      totalDepositToken,
    );
    discos[id] = d;
  }


  // 获取 disco
  function getDisco(string memory id) public view returns(
    address walletAddr,
    address tokenContract,
    string description,
    string fundRaisingTimeFrom,
    string fundRaisingTimeTo,
    uint256 investmentReward,
    uint256 rewardDeclineRate,
    uint256 shareToken,
    uint256 minFundRaising,
    uint256 addLiquidityPool,
    uint256 totalDepositToken,
  ) {
    return (
      discos[id].walletAddr,
      discos[id].walletAddr
      discos[id].tokenContract
      discos[id].description
      discos[id].fundRaisingTimeFrom
      discos[id].fundRaisingTimeTo
      discos[id].investmentReward
      discos[id].rewardDeclineRate
      discos[id].shareToken
      discos[id].minFundRaising
      discos[id].addLiquidityPool
      discos[id].totalDepositToken
    );
  }

}
