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
    // // 募资比例获得TOKEN
    // uint256 sharedToken;
    // // 奖励TOKEN
    // uint256 rewardedToken;
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

  struct DiscoInvestAddr {
    DiscoAddr discoAddr;
  }

  // 记录创建的disco
  mapping (string => DiscoInfo) public discos;
  // 记录投资人
  mapping (string => DiscoInvestor) public investors;
  // 记录投资的状态
  mapping (string => DiscoStatus) public status;
  // 记录 disco 的募资地址
  mapping (string => DiscoInvestAddr) public discoAddress;

  // 创建
  event createdDisco(string discoId, DiscoAddr addr);
  // 开启
  // event enabeldDisco(string discoId, address discoAddr);
  event enabeldDisco(string discoId);
  // 募资成功的时候
  event fundraisingSuccessed(string discoId);
  //募资结束（成功）
  event fundraisingFinished(string discoIdo);
  // 募资失败
  event fundraisingFailed(string discoId);
  // 投资者向 disco 投钱
  event investToDisco(string discoId, address investorAddr, uint amount);

  // 判断是否是本人
  modifier isOwner() {
    require(msg.sender == _owner);
    _;
  }

  constructor()
    public {
        _owner = msg.sender;
  }

  function setCoinBase (address payable addr)
      isOwner
      public {
        _coinbase = addr;
  }

  //  获取当前时间
  function getDate() public view returns(uint256){
    return now;
  }

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


    // 生成新的合约地址, discoAddr 既是DiscoAddr 的实例， 也是上链部署的地址
    DiscoAddr addr = new DiscoAddr(id);
    // disco id 与 disco 合约地址的映射
    // DiscoInvestAddr memory discoInvestAddr = DiscoInvestAddr(addr);
    // discoAddress[id] = discoInvestAddr;
       // disco 创建成功
    emit createdDisco(id, addr);
  }


  /**
   * @dev 开启disco
   */
  function enableDisco(string memory id) public {
    require(discos[id].fundRaisingStartedAt > getDate());
    require(discos[id].fundRaisingEndedAt < getDate());
    require(!status[id].isEnabled);

    status[id].isEnabled = true;
    // 发送开启募资的事件
    emit enabeldDisco(id);
  }



  /**
   * @dev 后端调用， 触发disco的结束， 由合约来判断disco的募资是否成功
   */
  function finishedDisco(string memory id) public {
    require(!status[id].isFinished);
    status[id].isFinished = true;

    // TODO 结束的时候需要检查募资是否成功或者失败
    status[id].isSuccess = true;
    // if ('成功') {
    //   status[id].isSuccess = true;
    //   // TODO 开启流动性 swap
    // } else {
    //   status[id].isSuccess = false;
    // }
    emit fundraisingFinished(id);
  }

  // 发起募资, 记录募资的信息， 可能会多次募资
  function investor(
    string memory id,
    address payable investorAddress,
    uint256 time) public payable{
     require(_coinbase != address(0));
     DiscoInvestor memory d = DiscoInvestor(
      investorAddress,
      msg.value,
      time
    );
    investors[id] = d;
    investorAddress.transfer(msg.value);

    emit investToDisco(id, investorAddress, msg.value);
  }
}

// 生成募资合约
contract DiscoAddr {

  string public id;
  // suppose the deployed contract has a purpose

  constructor(string memory discoId) public {
    id = discoId;
  }


  function getDiscoId() public view returns(string memory) {
    return id;
  }
}
