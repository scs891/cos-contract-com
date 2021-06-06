const UniswapV2Factory = artifacts.require("UniswapV2Factory");
feeToSetter="0xF98A7F9E86DCE7298F3be4778ACd692D649c5228";
module.exports = function (deployer) {
    deployer.deploy(UniswapV2Factory, feeToSetter);
 }