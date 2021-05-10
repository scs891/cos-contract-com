const Startup = artifacts.require('Startup')
const IRO = artifacts.require('IRO')
const Bounty = artifacts.require('Bounty')
const Disco = artifacts.require('Disco')
const Proposal = artifacts.require('Proposal')
const NumUtils = artifacts.require('libraries/NumUtils')

const UniswapV2Router01 = artifacts.require('UniswapV2Router01')
const factory = '0x87C91B6F127bEA8A5867B016334165749811831F' // prior to migrate the contract UniswapV2Factory on the network goerli
const weth = {
    mainnet: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
    ropsten: '0xc778417E063141139Fce010982780140Aa0cD5Ab',
    rinkeby: '0xc778417E063141139Fce010982780140Aa0cD5Ab',
    goerli: '0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6',
    kovan: '0xd0A1E359811322d97991E03f863a0C30C2cF029C',
}
module.exports = function (deployer) {
    deployer.deploy(Startup)
    deployer.deploy(IRO)
    deployer.deploy(Bounty)
    deployer.deploy(Disco)
    deployer.deploy(NumUtils)
    deployer.link(NumUtils, Proposal);
    deployer.deploy(Proposal, IRO.address, Disco.address)
    deployer.deploy(
        UniswapV2Router01,
        factory,
        weth[deployer.network.toString().replace('-fork', '')]
    )
}