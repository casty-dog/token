import { ethers } from "hardhat"
import { expect } from "chai"
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { time } from "@nomicfoundation/hardhat-network-helpers"

const contractName = "CastyToken"

async function deployContractFixture() {
  const contractFactory = await ethers.getContractFactory(contractName)
  const contract = await contractFactory.deploy()
  await contract.deployed()
  return contract
}

const initialSupply = ethers.utils.parseEther("10000000000")
const betweenMintsTime = 30 * 24 * 60 * 60

describe("CastyToken", function () {
  describe("deploy", function () {
    it("should initialize properly", async function () {
      const contract = await loadFixture(deployContractFixture)
      expect(await contract.name()).to.equal("CastyToken")
      expect(await contract.symbol()).to.equal("TY")
      expect(await contract.decimals()).to.equal(18)
      expect(await contract.totalSupply()).to.equal(initialSupply)
    })
    it("should mint initial supplied tokens to the owner", async function () {
      const [owner] = await ethers.getSigners()
      const contract = await loadFixture(deployContractFixture)
      const totalSupply = await contract.totalSupply()

      expect(await contract.balanceOf(owner.address)).to.equal(totalSupply)
    })
  })
  describe("mint", function () {
    it("mintable amount increase each 30 days", async function () {
      const contract = await loadFixture(deployContractFixture)
      const [owner] = await ethers.getSigners()
      const amount = initialSupply.mul(2).div(100)

      const mintTime = (await time.latest()) + betweenMintsTime
      await time.increaseTo(mintTime)
      expect(await contract.mintableAmount()).to.equal(amount)

      await contract.mint(owner.address, amount)
      expect(await contract.balanceOf(owner.address)).to.equal(initialSupply.add(amount))
    })

    it("should mint tokens to the owner", async function () {
      const [owner, account1] = await ethers.getSigners()
      const contract = await loadFixture(deployContractFixture)
      const amount = initialSupply.mul(2).div(100)

      const mintTime = (await time.latest()) + betweenMintsTime
      await time.increaseTo(mintTime)

      // not owner
      await expect(
        contract.connect(account1).mint(account1.address, amount)
      ).to.be.revertedWithCustomError(contract, "OwnableUnauthorizedAccount")

      // owner
      await contract.mint(owner.address, amount)
      expect(await contract.balanceOf(owner.address)).to.equal(initialSupply.add(amount))
    })
  })
})
