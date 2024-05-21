const entryPointABI =
  require("../artifacts/contracts/EntryPoint.sol/EntryPoint.json").abi;
const assetFactoryABI =
  require("../artifacts/contracts/AssetFactory.sol/AssetFactory.json").abi;
const assetTokenABI =
  require("../artifacts/contracts/mock/ModelERC20.sol/ModelERC20.json").abi;
const paymentTokenABI =
  require("../artifacts/contracts/mock/PaymentToken.sol/PaymentERC20.json").abi;

module.exports = {
  entryPointABI,
  assetFactoryABI,
  assetTokenABI,
  paymentTokenABI,
};
