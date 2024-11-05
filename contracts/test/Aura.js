const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");

describe("OnlyCars", function () {
  async function deployAuraFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const Aura = await ethers.getContractFactory("Aura");
    const aura = await Aura.deploy();

    return { aura, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should deploy successfully", async function () {
      const { aura } = await loadFixture(deployAuraFixture);
      expect(await aura.name()).to.equal("Aura");
      expect(await aura.symbol()).to.equal("AURA");
    });
  });

  // Add more tests for other functionalities...
});
