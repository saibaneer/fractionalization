const { createAsset } = require("../../structs");
const { signerBuilder, contractBuilder, unitsBuilder } = require("../builders");
const {
  entryPointABI,
  paymentTokenABI,
  assetTokenABI,
  assetFactoryABI,
} = require("../constants");

const createNewAsset = async (
  privateKey,
  rpcUrl,
  units,
  assetName,
  assetSymbol,
  assetUrl
) => {
  const asset = createAsset(
    unitsBuilder(units),
    assetName,
    assetSymbol,
    assetUrl
  );
  const signer = signerBuilder(privateKey, rpcUrl);

  const AssetFactory = contractBuilder(
    assetFactoryABI,
    process.env.ASSET_FACTORY_ADDRESS,
    signer
  );

  try {
    const tx = await AssetFactory.connect(signer).createNewAsset(asset);
    await tx.wait();
  } catch (error) {
    console.log("Creating the asset failed!");
    console.error(error);
  }
};

const updateAssetUrl = async (privateKey, rpcUrl, assetAddress, deedUrl) => {
  const signer = signerBuilder(privateKey, rpcUrl);

  const AssetFactory = contractBuilder(
    assetFactoryABI,
    process.env.ASSET_FACTORY_ADDRESS,
    signer
  );

  try {
    const tx = await AssetFactory.connect(signer).updateAssetUrl(
      assetAddress,
      deedUrl
    );
    await tx.wait();
  } catch (error) {
    console.log("Updating the asset URL failed!");
    console.error(error);
  }
};

const getAssetUrl = async (privateKey, rpcUrl, assetAddress) => {
  const signer = signerBuilder(privateKey, rpcUrl);

  const AssetFactory = contractBuilder(
    assetFactoryABI,
    process.env.ASSET_FACTORY_ADDRESS,
    signer
  );

  try {
    const assetUrl = await AssetFactory.connect(signer).getAssetUrl(
      assetAddress
    );
    return assetUrl;
  } catch (error) {
    console.log("Retrieving the asset URL failed!");
    console.error(error);
  }
};

const getAssetObject = async (privateKey, rpcUrl, assetAddress) => {
  const signer = signerBuilder(privateKey, rpcUrl);

  const AssetFactory = contractBuilder(
    assetFactoryABI,
    process.env.ASSET_FACTORY_ADDRESS,
    signer
  );

  try {
    const assetObject = await AssetFactory.connect(signer).getAssetObject(
      assetAddress
    );
    return assetObject;
  } catch (error) {
    console.log("Retrieving the asset object failed!");
    console.error(error);
  }
};

module.exports = {
  createNewAsset,
  updateAssetUrl,
  getAssetUrl,
  getAssetObject,
};
