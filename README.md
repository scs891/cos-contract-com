<!--
 * @Author: Zehui
 * @Date: 2020-07-11 23:56:36
 * @LastEditTime : 2021-06-04 20:57:20
 * @LastEditors  : Please set LastEditors
 * @Description: readme
 * @FilePath: \cos-contract-com\README.md
-->

# cos-contract-com

comunion 合约

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
1. comunion new start up 部署地址
   ```
     VUE_APP_STARTUP_RECEIVER = '0x2d065EBe8C310cE7c8d4169ab918261A5673b9E3'
   ```

2. comunion setting 部署地址

   ```
   VUE_APP_SETTING_RECEIVER = '0xE758f697F6409C3783Ad19c35847eC91F17F71f2'
   ```

3. comunion bounty 部署地址

   ```
   VUE_APP_BOUNTY_RECEIVER = '0x650996C9bb5EdE015B2876ace365F81a65884b20'
   ```

4. hunter 向 comunion 部署地址

   ```
   VUE_APP_HUNTER_FOR_COMUNION = '0x69EAB953C4a286Bb2216153EaA842d4c3e651aa2'
   ```

5. Disco 部署地址

   ```
   VUE_APP_DISCO_RECEIVER= '0xb3010A681B21167CfEcf1b47071b2D2154f25Fd9'
   ```

6. UNISWAPV2ROUTER01 的部署地址

   ```
   VUE_APP_UNISWAPV2ROUTER01 = '0xed83bf668568835e2feca667a57bebb21515bc65'
   ```

7. factory Address : 部署UniswapV2Router01前定义好的

   ```
   VUE_APP_SWAPROUTER01_FACTORY = '0x87C91B6F127bEA8A5867B016334165749811831F'
   ```

8. _WETH: 部署UniswapV2Router01前定义好的

   ```
   VUE_APP_SWAPROUTER01_WETH = '0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6'
   ```
9. proposal 部署合约地址

   ```
   VUE_APP_PROPOSAL = '0x0A78f8EcF6eFB0070B0A8Ab5E849bd491874869a'
   ```

