// Disco 上链
pragma solidity >=0.4.21 <0.7.0;


contract Disco {
  addrsss private _owner;

  modifier isOwner() {
    require(msg.sender == _owner);
    _;
  }


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


  constructor()
        public {
        _owner = msg.sender;
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
  function getDisco(string memory id) public view returns() {
    return ()
  }

}
