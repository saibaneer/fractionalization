const {
  signerBuilder,
  contractBuilder,
  unitsBuilder,
} = require("../builders");
const { entryPointABI, paymentTokenABI, assetTokenABI } = require("../constants");


const enterPosition = async (
  privateKey,
  rpcUrl,
  mdaoAssetAddress,
  acceptedStableCoinAddress,
  unitsOfToken
) => {
  const signer = signerBuilder(privateKey, rpcUrl);
  const EntryPoint = contractBuilder(
    entryPointABI,
    process.env.ENTRY_POINT_ADDRESS,
    signer
  );

  //approve the contract to spend the token
  const PaymentToken = contractBuilder(
    paymentTokenABI,
    acceptedStableCoinAddress,
    signer
  );

  try {
    const approveTx = await PaymentToken.connect(signer).approve(
      process.env.ENTRY_POINT_ADDRESS,
      unitsBuilder(unitsOfToken)
    );
    await approveTx.wait();
  } catch (error) {
    console.log("Approving the contract to spend the token failed!");
    console.error(error);
  }

  try {
    const tx = await EntryPoint.connect(signer).enterPosition(
      mdaoAssetAddress,
      acceptedStableCoinAddress,
      unitsBuilder(unitsOfToken)
    );
    await tx.wait();
  } catch (error) {
    console.log("Entering the position failed!");
    console.error(error);
  }
};

const listPositionForSale = async (
  privateKey,
  rpcUrl,
  unitsOfToken,
  pricePerUnitInBasisPoints
) => {
  const signer = signerBuilder(privateKey, rpcUrl);

  const EntryPoint = contractBuilder(
    entryPointABI,
    process.env.ENTRY_POINT_ADDRESS,
    signer
  );

  const AssetObject = contractBuilder(
    assetTokenABI,
    process.env.ASSET_ADDRESS,
    signer
  );

  try {
    const approveTx = await AssetObject.connect(signer).approve(
      process.env.ENTRY_POINT_ADDRESS,
      unitsBuilder(unitsOfToken)
    );
    await approveTx.wait();
  } catch (error) {
    console.log("Approving the contract to spend the token failed!");
    console.error(error);
  }

  try {
    const tx = await EntryPoint.connect(signer).listPositionForSale(
      process.env.ASSET_ADDRESS,
      process.env.TOKEN_ADDRESS,
      unitsBuilder(unitsOfToken),
      pricePerUnitInBasisPoints
    );
    await tx.wait();
  } catch (error) {
    console.log("Listing the position for sale failed!");
    console.error(error);
  }
};

const buyPosition = async (privateKey, rpcUrl, positionHash, unitsOfToken) => {
  const signer = signerBuilder(privateKey, rpcUrl);

  const EntryPoint = contractBuilder(
    entryPointABI,
    process.env.ENTRY_POINT_ADDRESS,
    signer
  );

  const PaymentToken = contractBuilder(
    paymentTokenABI,
    acceptedStableCoinAddress,
    signer
  );

  try {
    const approveTx = await PaymentToken.connect(signer).approve(
      process.env.ENTRY_POINT_ADDRESS,
      unitsBuilder(unitsOfToken)
    );
    await approveTx.wait();
  } catch (error) {
    console.log("Approving the entrypoint contract to spend the token failed!");
    console.error(error);
  }

  try {
    const tx = await EntryPoint.connect(signer).buyPosition(
      positionHash,
      unitsBuilder(unitsOfToken)
    );
    await tx.wait();
  } catch (error) {
    console.log("Buying the position failed!");
    console.error(error);
  }
};

const delistPosition = async (
  privateKey,
  rpcUrl,
  positionHash,
  unitsOfToken
) => {
  const signer = signerBuilder(privateKey, rpcUrl);

  const EntryPoint = contractBuilder(
    entryPointABI,
    process.env.ENTRY_POINT_ADDRESS,
    signer
  );

  try {
    const tx = await EntryPoint.connect(signer).delistPosition(
      positionHash,
      unitsBuilder(unitsOfToken)
    );
    await tx.wait();
  } catch (error) {
    console.log("Delisting the position failed!");
    console.error(error);
  }
};

const setAllowedToken = async (
  privateKey,
  rpcUrl,
  acceptedTokenAddress,
  isTokenAccepted
) => {
  const signer = signerBuilder(privateKey, rpcUrl);

  const EntryPoint = contractBuilder(
    entryPointABI,
    process.env.ENTRY_POINT_ADDRESS,
    signer
  );

  try {
    const tx = await EntryPoint.connect(signer).setAllowedToken(
      acceptedTokenAddress,
      isTokenAccepted
    );
    await tx.wait();
  } catch (error) {
    console.log("Setting the allowed token failed!");
    console.error(error);
  }
};

const setVaultAddress = async (privateKey, rpcUrl) => {
  const signer = signerBuilder(privateKey, rpcUrl);

  const EntryPoint = contractBuilder(
    entryPointABI,
    process.env.ENTRY_POINT_ADDRESS,
    signer
  );

  try {
    const tx = await EntryPoint.connect(signer).setVaultAddress(
      process.env.VAULT_ADDRESS
    );
    await tx.wait();
  } catch (error) {
    console.log("Setting the vault address failed!");
    console.error(error);
  }
};

const setFactoryAddress = async (privateKey, rpcUrl) => {
  const signer = signerBuilder(privateKey, rpcUrl);

  const EntryPoint = contractBuilder(
    entryPointABI,
    process.env.ENTRY_POINT_ADDRESS,
    signer
  );

  try {
    const tx = await EntryPoint.connect(signer).setFactoryAddress(
      process.env.FACTORY_ADDRESS
    );
    await tx.wait();
  } catch (error) {
    console.log("Setting the factory address failed!");
    console.error(error);
  }
};

module.exports = {
  enterPosition,
  listPositionForSale,
  buyPosition,
  delistPosition,
  setAllowedToken,
  setVaultAddress,
  setFactoryAddress,
};
