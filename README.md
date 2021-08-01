<!--
 * @Author: Zehui
 * @Date: 2020-07-11 23:56:36
 * @LastEditors  : Please set LastEditors
 * @Description: readme
-->

# 合约如何搭建本地环境

1. 使用 npm 安装 remixd 工具，该工具会在本地建立一个 websocket 服务器，然后就可以使用网页 remix 端与其进行连接了， 运行命令
   ```
       npm install -g @remix-project/remixd
   ```
2. 打开 remix (https://remix.ethereum.org)
3. 启动,

   ```
    remixd -s  [你的源码目录] --remix-ide  https://remix.ethereum.org
   ```

   在当前项目中， 我已经为大家配置好了， 直接运行

   ```
    yarn remixed
   ```

4. 打开 “https://remix.ethereum.org/#optimize=true&runs=200”
   点击 Home -> file -> connect to local host;
5. 可以看到左侧的侧边栏 loading 本地文件
6. loading 后 happy coding
7. 如果是本地调试， 没有必要部署测试网：
   1. 在 remix: Deploy -> environment -> javascript VM （浏览器内存有限， 部署多了会崩）
   2. 本地安装 gaanche, Deploy -> environment -> web3 Provider (原理是利用本机内存搭建了一个私链，纵享丝滑吧)
   3. 如果需要与后端调试， 需要部署在测试网

# uniswap 部署过程

1. 先部署 factory 得到 address1
2. 在部署 ERc20 合约， tokenzehu1（ 真实部署 \_WETH 的地址）
3. 再部署 ERC20 合约， tokenzehui2
4. 使用 address1, 和 tokenzehui1 的地址部署 router01 得到 address2
5. tokenzehu1 approval 给 address2; tokenzehui2 approval 给 address2
6. 调用 address2 的 addLiquidy 方法

# cos-contract-com comunion 合约介绍

- Startup.sol 对应 startup 的合约
- IRO.sol 对应 Setting 的合约
- Bounty.sol 对应 bounty 的合约
- Disco.sol 对应 DISCO 的合约
- UniswapV2Router01.sol

# 文件结构说明

- contracts 目录下是合约文件
- migrations 合约部署

# 说明

- 合约由 truffle 初始化创建
- 编译： truffle compile
- 部署： truffle migrate

# Additional

1. prior to migrate UniswapV2Factory
2. UniswapV2Factory: https://github.com/Uniswap/uniswap-v2-core

# 合约的部署地址, 请部署后及时更新， 前端需要从此处获取地址信息来创建合约

# [Contract & Abi] 合约的部署地址, 请部署后及时更新， 前端需要从此处获取地址信息来创建合约 ，下划线开头的将忽略
1. start-up 
   - address: 0x865F46B2aF27f76D41FaBE8dE2495911E487c8cE
   - abi: contracts/artifacts/Startup.json
2. setting 
   - address: 0x9aF69ed56499011eC8E440b7c2D7FD7fc79d7268
   - abi: contracts/artifacts/IRO.json
3. bounty
   - address: 0x07B5427f3D7c5c6CfbbD13816900bbd05B9f1c98
   - abi: contracts/artifacts/Bounty.json
4. disco
   - address: 0xB39475E3077591c0f1E79b2BEdcbC9501F48E307
   - abi: contracts/artifacts/Disco.json
5. proposal
   - address: 0xc712C20191f95eeA053350De574de46D88AD9F38
   - abi: contracts/artifacts/Proposal.json
6. hunter
   - address: 0x69EAB953C4a286Bb2216153EaA842d4c3e651aa2
   - abi: null
7. UNISWAPV2ROUTER01
   - address: 0xa37fB09aA7bc4c0f18C9503c397BdB255BD6daa2
   - abi: null
8. factory
   - comment: 部署UniswapV2Router01前定义好的
   - address: 0x1AB23C05C7Dfd5f11C4fB3dc497C1F57e1B14740
   - abi: null
9. _WETH
   - comment: 部署UniswapV2Router01前定义好的
   - address: 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6
   - abi: null

   

