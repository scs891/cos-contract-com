const Startup = artifacts.require('Startup')
const IRO = artifacts.require('IRO')
const Bounty = artifacts.require('Bounty')

module.exports = function (deployer) {
	deployer.deploy(Startup)
	deployer.deploy(IRO)
	deployer.deploy(Bounty)
}
