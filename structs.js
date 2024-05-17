const { ethers } = require("ethers");
const BigNumber = require('bignumber.js');

function createAsset(units, assetName, assetSymbol, assetUrl) {
    
    if (typeof units !== 'number') throw new Error('Invalid units');
    if (typeof assetName !== 'string') throw new Error('Invalid assetName');
    if (typeof assetSymbol !== 'string') throw new Error('Invalid assetSymbol');
    if (typeof assetUrl !== 'string') throw new Error('Invalid assetUrl');

    return {
        units: ethers.parseEther(units.toString()),
        assetAddress: ethers.ZeroAddress,
        assetName: assetName,
        assetSymbol: assetSymbol,
        assetUrl: assetUrl
    };
}

// Define the structure of a Position
function createPosition(hashId, assetAddress, preferredTokenForSale, owner, units, price, nonce) {
    if (typeof hashId !== 'string') throw new Error('Invalid hashId');
    if (typeof assetAddress !== 'string') throw new Error('Invalid assetAddress');
    if (typeof preferredTokenForSale !== 'string') throw new Error('Invalid preferredTokenForSale');
    if (typeof owner !== 'string') throw new Error('Invalid owner');
    if (typeof units !== 'number') throw new Error('Invalid units');
    if (typeof price !== 'number') throw new Error('Invalid price');
    if (typeof nonce !== 'number') throw new Error('Invalid nonce');
    return {
        hashId: hashId,
        assetAddress: assetAddress,
        preferredTokenForSale: preferredTokenForSale,
        owner: owner,
        units: units,
        price: price,
        nonce: nonce
    };
}

module.exports = {
    createAsset,
    createPosition
}