const Startup = artifacts.require("Startup");
const IRO = artifacts.require("IRO");

module.exports = function(deployer) {
  deployer.deploy(Startup);
  deployer.deploy(IRO);
};