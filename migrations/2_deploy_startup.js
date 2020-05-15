const Startup = artifacts.require("Startup");

module.exports = function(deployer) {
  deployer.deploy(Startup);
};