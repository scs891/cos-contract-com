// Disco 上链
pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;

contract Disco {
    address private _owner;
    address payable private _coinbase;


    // disco
    struct DiscoInfo {
        string id;
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
    mapping(string => DiscoInfo) public discos;
    // 记录投资人
    mapping(string => DiscoInvestor) public investors;
    // 记录投资的状态
    mapping(string => DiscoStatus) public status;
    // 记录 disco 的募资地址
    mapping(string => DiscoInvestAddr) public discoAddress;

    // 创建
    event createdDisco(string discoId, DiscoAddr addr);
    // 开启
    // event enabledDisco(string discoId, address discoAddr);
    event enabledDisco(string discoId);
    // 募资成功的时候
    event fundraisingSucceed(string discoId);
    //募资结束（成功）
    event fundraisingFinished(string discoIdo);
    // 募资失败
    event fundraisingFailed(string discoId);
    // 投资者向 disco 投钱
    event investToDisco(string discoId, address investorAddr, uint amount);

    // 判断是否是本人
    modifier isOwner() {
        require(msg.sender == _owner, "Caller is not owner!");
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
    function getDate() public view returns (uint256){
        return now;
    }

    // 创建Disco
    /**
    * @param d  tuple forward.
    **/
    function newDisco(DiscoInfo memory d) public payable {
        require(bytes(d.id).length != 0);
        DiscoStatus memory s = DiscoStatus(
            false,
            false,
            false
        );
        discos[d.id] = d;
        status[d.id] = s;
        // 生成新的合约地址, discoAddr 既是DiscoAddr 的实例， 也是上链部署的地址
        DiscoAddr addr = new DiscoAddr(d.id);
        // disco id 与 disco 合约地址的映射
        DiscoInvestAddr memory discoInvestAddr = DiscoInvestAddr(addr);
        discoAddress[d.id] = discoInvestAddr;
        // disco 创建成功
        emit createdDisco(d.id, addr);
    }


    /**
     * @dev 开启disco
     */
    function enableDisco(string memory id) public {
        uint256 checkPoint = getDate();
        require(discos[id].fundRaisingStartedAt < checkPoint, '当前时间需要大于disco的开始募资时间');
        require(discos[id].fundRaisingEndedAt > checkPoint, '当前时间需要小于disco的结束募资时间');
        require(!status[id].isEnabled, '当前disco需要未被开启过');

        status[id].isEnabled = true;
        // 发送开启募资的事件
        emit enabledDisco(id);
    }



    /**
     * @dev 后端调用， 触发disco的结束， 由合约来判断disco的募资是否成功
     */
    function finishedDisco(string calldata id) external {
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
    function investor(string memory id, uint256 time) public payable {
        require(_coinbase != address(0));
        DiscoInvestor memory d = DiscoInvestor(
            _owner,
            msg.value,
            time
        );

        investors[id] = d;

        DiscoAddr discoAddr = discoAddress[id].discoAddr;
        address(discoAddr).transfer(msg.value);

        emit investToDisco(id, _owner, msg.value);
    }
}


// 生成募资合约
contract DiscoAddr {

    string public id;
    // suppose the deployed contract has a purpose

    receive() external payable {}

    constructor(string memory discoId) public {
        id = discoId;
    }


    function getDiscoId() public view returns (string memory) {
        return id;
    }
}
