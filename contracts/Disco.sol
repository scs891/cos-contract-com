// Disco 上链
pragma solidity >=0.4.21 <0.7.0;

contract Disco {
  address private _owner;
  address payable private _coinbase;


  // disco
  struct DiscoInfo {
    address walletAddr;
    address tokenAddr;
    string description;
    uint256 fundRaisingStartedAt;
    uint256 fundRaisingEndedAt;
    uint256 investmentReward;
    uint256 rewardDeclineRate;
    uint256 shareToken;
    uint256 minFundRaising;
    uint256 addLiquidityPool;
    uint256 totalDepositToken;
  }

  // disco 投资人信息
  struct DiscoInvestor {
    // 投资人地址
    address investor;
    // 投资金额, 可以多次投资
    uint value;
     // 时间
    uint time;
    // 募资比例获得TOKEN
    uint256 sharedToken;
    // 奖励TOKEN
    uint256 rewardedToken;
  }

  // disco的状态
  struct DiscoStatus {
    // 募资是否结束
    bool isFinished;
    // 募资是否成功
    bool isSuccess;
    // 募资是否开启；
    bool isEnabled;
  }

  // 记录创建的disco
  mapping (string => DiscoInfo) public discos;
  // 记录投资人
  mapping (string => DiscoInvestor) public investors;
  // 记录投资的状态
  mapping (string => DiscoStatus) public status;

  // 创建
  event createdDisco(string discoId);
  // 开启
  event enabeldDisco(string discoId);
  // 募资成功的时候
  event fundraisingSuccessed(string discoId);
  //募资结束（成功）
  event fundraisingFinished(string discoIdo);
  // 募资失败
  event fundraisingFailed(string discoId);
  // 投资者向 disco 投钱
  event investToDisco(string discoId);

  // 判断是否是本人
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

  //  获取当前时间
  function getDate() public view returns(uint256){
    return now;
  }

   /**
     * 募资转账 TODO
    */
  // function () payable {
  //     // require('募资没有结束');
  //     uint amount = msg.value;
  //     balanceOf[msg.sender] += amount;
  //     // amountRaised += amount;
  //     // tokenReward.transfer(msg.sender, amount / price);
  //     // TODO
  //     FundTransfer(msg.sender, amount, true);
  // }


   // 创建Disco
  function newDisco(
    string memory id,
    address walletAddr,
    address tokenAddr,
    string memory description,
    uint256 fundRaisingStartedAt,
    uint256 fundRaisingEndedAt,
    uint256 investmentReward,
    uint256 rewardDeclineRate,
    uint256 shareToken,
    uint256 minFundRaising,
    uint256 addLiquidityPool,
    uint256 totalDepositToken
  ) public payable {
    require(_coinbase != address(0));
    DiscoInfo memory d = DiscoInfo(
      walletAddr,
      tokenAddr,
      description,
      fundRaisingStartedAt,
      fundRaisingEndedAt,
      investmentReward,
      rewardDeclineRate,
      shareToken,
      minFundRaising,
      addLiquidityPool,
      totalDepositToken
    );
    DiscoStatus memory s = DiscoStatus(
      false,
      false,
      false
    );
    discos[id] = d;
    status[id] = s;

    // disco 创建成功
    emit createdDisco(id);
  }

    // 开启募资
  function enableDisco(string memory id) public {
    require(discos[id].fundRaisingStartedAt > now);
    require(discos[id].fundRaisingEndedAt < now);
    require(!status[id].isEnabled);
    status[id].isEnabled = true;
    // 发送开启募资的事件
    emit enabeldDisco(id);
  }


  // function getDisco(string memory id) public view returns(string DiscoInfo) {
  //   return discos[id];
  // }

  // // 募资结束
  // function finishedDisco(string memory id) public returns(bool) {
  //   require(!status[id].isFinished);
  //   status[id].isFinished = true;

  //   // TODO 结束的时候需要检查募资是否成功或者失败
  //   if ('成功') {
  //     status[id].isSuccess = true;
  //     // TODO 开启流动性 swap
  //   } else {
  //     status[id].isSuccess = false;
  //   }
  //   emit fundraisingFinished(id);
  // }

  // 发起募资, 记录募资的信息， 可能会多次募资
  function investor(
      string memory id,
      address investorAddress,
      uint256 value,
      uint256 time,
      uint256 sharedToken,
      uint256 rewardedToken
    ) public {
     DiscoInvestor memory i = DiscoInvestor(
      investorAddress,
      value,
      time,
      sharedToken,
      rewardedToken
    );
    investors[id] = i;
  }
}
