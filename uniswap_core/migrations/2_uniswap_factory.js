const UniswapV2Factory = artifacts.require("UniswapV2Factory");
feeToSetter="0x49bF483874A9842eEa79819FC51E16e126445001";
module.exports = function (deployer) {
    deployer.deploy(UniswapV2Factory, feeToSetter);
 }