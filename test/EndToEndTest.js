// - Deploy the Asset Factory
// - Capture the Asset Address
// - Deploy a payment ERC20
// - Use the payment ERC20 to "Enter Position"
// - Having Entered a Position, "List a Position for Sale"
// - Having Listed a Position for Sale, Use a second user to buy that position
// - Having Listed a Position for Sale, "Delist Some of the Position"
// - Having Listed a Position for Sale, "Delist All of the Position"

const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { createAsset, createPosition } = require("../structs");

describe("EndToEnd Tests", function () {
  async function deployAssetFactoryFixture() {
    const [owner, alice, bob] = await ethers.getSigners();
    const AssetFactory = await ethers.getContractFactory("AssetFactory");
    const assetFactory = await AssetFactory.deploy();
    return { assetFactory, owner };
  }

  async function deployPaymentERC20Fixture() {
    const [owner, alice, bob] = await ethers.getSigners();
    const PaymentERC20 = await ethers.getContractFactory("PaymentERC20");
    const paymentERC20 = await PaymentERC20.deploy();
    return { paymentERC20, owner };
  }
  describe("Create New Asset Test", function() {

    it("should create a new asset", async function(){
        const {assetFactory, owner} = await loadFixture(deployAssetFactoryFixture);
        const mdaoAsset = createAsset(100, "HomeAsset123", "MDAO", "https://mdao.com");
        await assetFactory.connect(owner).createNewAsset(mdaoAsset);
    })


    describe.skip("Enter Position Test", function(){

        describe("List Position for Sale Test", function(){

            describe("Buy Position Test", function(){})
            describe("Delist Some of the Position Test", function(){})
            describe("Delist All of the Position Test", function(){})

        })

    })



  })
});
