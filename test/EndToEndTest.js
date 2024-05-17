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
const { ethers } = require("hardhat");

describe("EndToEnd Tests", function () {
  async function deployAssetFactoryFixture() {
    const [owner, alice, bob] = await ethers.getSigners();
    const AssetFactory = await ethers.getContractFactory("AssetFactory");
    const assetFactory = await AssetFactory.deploy();
    return { assetFactory, owner, alice, bob };
  }

  async function deployPaymentERC20Fixture() {
    const [owner, alice, bob] = await ethers.getSigners();
    const PaymentERC20 = await ethers.getContractFactory("PaymentERC20");
    const paymentERC20 = await PaymentERC20.deploy(5000);
    return { paymentERC20, owner };
  }

  async function deployEntryPointFixture() {
    const [owner, alice, bob] = await ethers.getSigners();
    const EntryPoint = await ethers.getContractFactory("EntryPoint");
    const entryPoint = await EntryPoint.deploy(owner.address);
    return { entryPoint, owner, alice, bob };
  }

  async function deployVaultFixture() {
    const [owner, alice, bob] = await ethers.getSigners();
    const Vault = await ethers.getContractFactory("Vault");
    const vault = await Vault.deploy();
    return { vault, owner, alice, bob };
  }
  describe("Create New Asset Test", function() {

    it("should create a new asset", async function(){
        const {assetFactory, owner} = await loadFixture(deployAssetFactoryFixture);
        const mdaoAsset = createAsset(100, "HomeAsset123", "MDAO", "https://mdao.com");
        
        const tx = await assetFactory.connect(owner).createNewAsset(mdaoAsset);
        const assetCreatedEvent = assetFactory.filters.CreatedNewAsset();
        let events = await assetFactory.queryFilter(assetCreatedEvent, "latest");
        // console.log(events[0].args[0]);
        const assetAddress = events[0].args[0][1];
        const assetObject = await assetFactory.getAsset(assetAddress);
        expect(assetObject.assetAddress).to.equal(assetAddress);
        expect(assetObject.assetName).to.equal("HomeAsset123");
        expect(assetObject.assetSymbol).to.equal("MDAO");
        expect(assetObject.assetUrl).to.equal("https://mdao.com");
        const tokenContract = await ethers.getContractAt("ModelERC20", assetAddress);
        expect(await tokenContract.maxSupply()).to.equal(ethers.parseEther("100"));
        // console.log(assetObject);
    })


    describe("Enter Position Test", function(){

        it("should enter a position", async function(){
            const {assetFactory, owner, alice } = await loadFixture(deployAssetFactoryFixture);
            const {paymentERC20} = await loadFixture(deployPaymentERC20Fixture);
            const {entryPoint} = await loadFixture(deployEntryPointFixture);
            const {vault} = await loadFixture(deployVaultFixture);

            const mdaoAsset = createAsset(100, "HomeAsset123", "MDAO", "https://mdao.com");
            const tx = await assetFactory.connect(owner).createNewAsset(mdaoAsset);
            const assetCreatedEvent = assetFactory.filters.CreatedNewAsset();
            let events = await assetFactory.queryFilter(assetCreatedEvent, "latest");
            const assetAddress = events[0].args[0][1];
            const assetObject = await ethers.getContractAt("ModelERC20", assetAddress);

            expect(await assetObject.balanceOf(alice.address)).to.equal(0);
            await paymentERC20.connect(owner).mint(alice.address, ethers.parseEther("20"));
            await paymentERC20.connect(alice).approve(await entryPoint.getAddress(), ethers.parseEther("20"));
            await entryPoint.connect(owner).setAllowedToken(await paymentERC20.getAddress(), true);
            await entryPoint.connect(owner).setVaultAddress(await vault.getAddress());
            await entryPoint.connect(owner).setFactoryAddress(await assetFactory.getAddress());
            
            
            await entryPoint.connect(alice).enterPosition(assetAddress, await paymentERC20.getAddress(), ethers.parseEther("20"));
            expect(await assetObject.balanceOf(alice.address)).to.equal(ethers.parseEther("20"));
            expect(await paymentERC20.balanceOf(alice.address)).to.equal(0);
            
        })

        describe("List Position for Sale Test", function(){
            it("should list a position for sale", async function(){
                const {assetFactory, owner, alice } = await loadFixture(deployAssetFactoryFixture);
                const {paymentERC20} = await loadFixture(deployPaymentERC20Fixture);
                const {entryPoint} = await loadFixture(deployEntryPointFixture);
                const {vault} = await loadFixture(deployVaultFixture);
    
                const mdaoAsset = createAsset(100, "HomeAsset123", "MDAO", "https://mdao.com");
                const tx = await assetFactory.connect(owner).createNewAsset(mdaoAsset);
                let assetCreatedEvent = assetFactory.filters.CreatedNewAsset();
                let events = await assetFactory.queryFilter(assetCreatedEvent, "latest");
                const assetAddress = events[0].args[0][1];
                const assetObject = await ethers.getContractAt("ModelERC20", assetAddress);
    
                expect(await assetObject.balanceOf(alice.address)).to.equal(0);
                await paymentERC20.connect(owner).mint(alice.address, ethers.parseEther("20"));
                await paymentERC20.connect(alice).approve(await entryPoint.getAddress(), ethers.parseEther("20"));
                await entryPoint.connect(owner).setAllowedToken(await paymentERC20.getAddress(), true);
                await entryPoint.connect(owner).setVaultAddress(await vault.getAddress());
                await entryPoint.connect(owner).setFactoryAddress(await assetFactory.getAddress());
                
                
                await entryPoint.connect(alice).enterPosition(assetAddress, await paymentERC20.getAddress(), ethers.parseEther("20"));
                expect(await assetObject.balanceOf(alice.address)).to.equal(ethers.parseEther("20"));
                expect(await paymentERC20.balanceOf(alice.address)).to.equal(0);
                
                await assetObject.connect(alice).approve(await entryPoint.getAddress(), ethers.parseEther("5"));
                await entryPoint.connect(alice).listPositionForSale(assetAddress, await paymentERC20.getAddress(), ethers.parseEther("5"), 150);

                assetCreatedEvent = entryPoint.filters.ListedPositionForSale();
                events = await entryPoint.queryFilter(assetCreatedEvent, "latest");
                let eventObj = events[0].args;
                // console.log(eventObj[5]);
                const positionHash = eventObj[5];
                const position = await entryPoint.positionHashToAsset(positionHash);
                const userPositions = await entryPoint.getUserPositions(await alice.getAddress());
                expect(userPositions[0]).to.deep.equal(position);
    
            })
            describe.skip("Buy Position Test", function(){})
            describe.skip("Delist Some of the Position Test", function(){})
            describe.skip("Delist All of the Position Test", function(){})

        })

    })



  })
});
