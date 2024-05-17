const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");
const { createAsset } = require("../structs");
const { ethers } = require("hardhat");

const emptyResult = [
  '0x0000000000000000000000000000000000000000000000000000000000000000',
  '0x0000000000000000000000000000000000000000',
  '0x0000000000000000000000000000000000000000',
  '0x0000000000000000000000000000000000000000',
  0n,
  0n,
  0n
];

describe("EndToEnd Tests", function () {
  async function deployContractsFixture() {
    const [owner, alice, bob] = await ethers.getSigners();
    
    const AssetFactory = await ethers.getContractFactory("AssetFactory");
    const assetFactory = await AssetFactory.deploy();

    const PaymentERC20 = await ethers.getContractFactory("PaymentERC20");
    const paymentERC20 = await PaymentERC20.deploy(5000);

    const EntryPoint = await ethers.getContractFactory("EntryPoint");
    const entryPoint = await EntryPoint.deploy(owner.address);

    const Vault = await ethers.getContractFactory("Vault");
    const vault = await Vault.deploy();

    return { assetFactory, paymentERC20, entryPoint, vault, owner, alice, bob};
  }

  async function createNewAsset(assetFactory, owner) {
    const mdaoAsset = createAsset(100, "HomeAsset123", "MDAO", "https://mdao.com");
    await assetFactory.connect(owner).createNewAsset(mdaoAsset);
    
    const assetCreatedEvent = assetFactory.filters.CreatedNewAsset();
    const events = await assetFactory.queryFilter(assetCreatedEvent, "latest");
    const assetAddress = events[0].args[0][1];

    const assetObject = await assetFactory.getAsset(assetAddress);
    const tokenContract = await ethers.getContractAt("ModelERC20", assetAddress);

    return { assetObject, tokenContract, assetAddress };
  }

  describe("Create New Asset Test", function () {
    it("should create a new asset", async function () {
      const { assetFactory, owner } = await loadFixture(deployContractsFixture);
      const { assetObject, assetAddress } = await createNewAsset(assetFactory, owner);

      expect(assetObject.assetAddress).to.equal(assetAddress);
      expect(assetObject.assetName).to.equal("HomeAsset123");
      expect(assetObject.assetSymbol).to.equal("MDAO");
      expect(assetObject.assetUrl).to.equal("https://mdao.com");

      const tokenContract = await ethers.getContractAt("ModelERC20", assetAddress);
      expect(await tokenContract.maxSupply()).to.equal(ethers.parseEther("100"));
    });
  });

  describe("Position Tests", function () {
    beforeEach(async function () {
      const fixtures = await loadFixture(deployContractsFixture);
      Object.assign(this, fixtures);
        
      
      const { assetFactory, owner, alice, entryPoint, vault, paymentERC20 } = this;
      await entryPoint.connect(owner).setAllowedToken(await paymentERC20.getAddress(), true);
      await entryPoint.connect(owner).setVaultAddress(await vault.getAddress());
      await entryPoint.connect(owner).setFactoryAddress(await assetFactory.getAddress());

      const { tokenContract, assetAddress } = await createNewAsset(assetFactory, owner);
      this.assetObject = tokenContract;
      this.assetAddress = assetAddress;

      await paymentERC20.connect(owner).mint(alice.address, ethers.parseEther("20"));
    });

    it("should enter a position", async function () {
      const { alice, entryPoint, paymentERC20, assetObject, assetAddress } = this;
      await paymentERC20.connect(alice).approve(await entryPoint.getAddress(), ethers.parseEther("20"));
      await entryPoint.connect(alice).enterPosition(assetAddress, await paymentERC20.getAddress(), ethers.parseEther("20"));

      expect(await assetObject.balanceOf(alice.address)).to.equal(ethers.parseEther("20"));
      expect(await paymentERC20.balanceOf(alice.address)).to.equal(0);
    });

    it("should list a position for sale", async function () {
      const { alice, entryPoint, assetObject, paymentERC20, assetAddress } = this;
      await paymentERC20.connect(alice).approve(await entryPoint.getAddress(), ethers.parseEther("20"));
      await entryPoint.connect(alice).enterPosition(assetAddress, await paymentERC20.getAddress(), ethers.parseEther("20"));

      await assetObject.connect(alice).approve(await entryPoint.getAddress(), ethers.parseEther("5"));
      await entryPoint.connect(alice).listPositionForSale(assetAddress, await paymentERC20.getAddress(), ethers.parseEther("5"), 150);

      const assetCreatedEvent = entryPoint.filters.ListedPositionForSale();
      const events = await entryPoint.queryFilter(assetCreatedEvent, "latest");
      const eventObj = events[0].args;
      const positionHash = eventObj[5];

      const position = await entryPoint.positionHashToAsset(positionHash);
      const userPositions = await entryPoint.getUserPositions(alice.address);
      expect(userPositions[0]).to.deep.equal(position);
    });

    it("should allow another user to buy a position", async function () {
      const { alice, bob, entryPoint, assetObject, paymentERC20, assetAddress, owner } = this;
      await paymentERC20.connect(alice).approve(await entryPoint.getAddress(), ethers.parseEther("20"));
      await paymentERC20.connect(owner).mint(bob.address, ethers.parseEther("200"));

      await entryPoint.connect(alice).enterPosition(assetAddress, await paymentERC20.getAddress(), ethers.parseEther("20"));
      await assetObject.connect(alice).approve(await entryPoint.getAddress(), ethers.parseEther("5"));
      await entryPoint.connect(alice).listPositionForSale(assetAddress, await paymentERC20.getAddress(), ethers.parseEther("5"), 15000);

      const assetCreatedEvent = entryPoint.filters.ListedPositionForSale();
      const events = await entryPoint.queryFilter(assetCreatedEvent, "latest");
      const positionHash = events[0].args[5];

      await paymentERC20.connect(bob).approve(await entryPoint.getAddress(), ethers.parseEther("20"));
      await entryPoint.connect(bob).buyPosition(positionHash, ethers.parseEther("5"));

      expect(await assetObject.balanceOf(bob.address)).to.equal(ethers.parseEther("5"));
      expect(await paymentERC20.balanceOf(bob.address)).to.equal(ethers.parseEther("192.5"));
      expect(await paymentERC20.balanceOf(alice.address)).to.equal(ethers.parseEther("7.5"));
    });

    it("should allow a user to delist some of their position", async function () {
      const { alice, entryPoint, assetObject, paymentERC20, assetAddress } = this;
      await paymentERC20.connect(alice).approve(await entryPoint.getAddress(), ethers.parseEther("20"));
      await entryPoint.connect(alice).enterPosition(assetAddress, await paymentERC20.getAddress(), ethers.parseEther("20"));
      await assetObject.connect(alice).approve(await entryPoint.getAddress(), ethers.parseEther("5"));
      await entryPoint.connect(alice).listPositionForSale(assetAddress, await paymentERC20.getAddress(), ethers.parseEther("5"), 15000);

      const assetCreatedEvent = entryPoint.filters.ListedPositionForSale();
      const events = await entryPoint.queryFilter(assetCreatedEvent, "latest");
      const positionHash = events[0].args[5];

      await entryPoint.connect(alice).delistPosition(positionHash, ethers.parseEther("2"));
      const updatedPosition = await entryPoint.positionHashToAsset(positionHash);
      expect(updatedPosition.units).to.equal(ethers.parseEther("3"));
    });

    it("should allow a user to delist all of their position", async function () {
      const { alice, entryPoint, assetObject, paymentERC20, assetAddress } = this;
      await paymentERC20.connect(alice).approve(await entryPoint.getAddress(), ethers.parseEther("20"));
      await entryPoint.connect(alice).enterPosition(assetAddress, await paymentERC20.getAddress(), ethers.parseEther("20"));
      await assetObject.connect(alice).approve(await entryPoint.getAddress(), ethers.parseEther("5"));
      await entryPoint.connect(alice).listPositionForSale(assetAddress, await paymentERC20.getAddress(), ethers.parseEther("5"), 15000);

      const assetCreatedEvent = entryPoint.filters.ListedPositionForSale();
      const events = await entryPoint.queryFilter(assetCreatedEvent, "latest");
      const positionHash = events[0].args[5];

      await entryPoint.connect(alice).delistPosition(positionHash, ethers.parseEther("5"));
      const updatedPosition = await entryPoint.positionHashToAsset(positionHash);
      const userPositions = await entryPoint.getUserPositions(alice.address);

      expect(updatedPosition).to.deep.equal(emptyResult);
      expect(userPositions).to.be.empty;
    });
  });
});
