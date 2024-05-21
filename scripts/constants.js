const entryPointABI =
  require("./abis/EntryPoint.sol/EntryPoint.json").abi;
const assetFactoryABI =
  require("./abis/AssetFactory.sol/AssetFactory.json").abi;
const assetTokenABI =
  require("./abis/mock/ModelERC20.sol/ModelERC20.json").abi;
const paymentTokenABI =
  require("./abis/mock/PaymentToken.sol/PaymentERC20.json").abi;

module.exports = {
  entryPointABI,
  assetFactoryABI,
  assetTokenABI,
  paymentTokenABI,
};
