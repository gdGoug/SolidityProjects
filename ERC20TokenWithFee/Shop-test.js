const {expect} = require("chai")
const {ethers} = require("hardhat")
const tokenJSON = require("../artifacts/contracts/Lesson_13.ERC.sol/piPhychyToken.json")

describe("Shop", function(){
    let owner
    let buyer
    let shop 
    let erc20

    beforeEach(async function(){
        [owner, buyer] = await ethers.getSigners()

        const Shop = await ethers.getContractFactory("PhychyShop", owner)
        shop = await Shop.deploy()
        await shop.deployed()

        erc20 = new ethers.Contract(await shop.token(), tokenJSON.abi, owner)


    })

    it("should have an owner and a token", async function(){
        expect(await shop.owner()).to.eq(owner.address)
        expect(await shop.token()).to.be.properAddress
    })

    it("allows to buy", async function(){
        const tokenAmount = 10;

        const txData = {value: tokenAmount, to: shop.address}

        const tx = await buyer.sendTransaction(txData)
        await tx.wait()

        expect(await erc20.balanceOf(buyer.address)).to.eq(tokenAmount)

        await expect(() => tx).to.changeEtherBalance(shop, tokenAmount)

        await expect(tx).to.emit(shop, "Bought").withArgs(tokenAmount, buyer.address)
    })

    it("allows to sell", async function(){
        const tx = await buyer.sendTransaction({value: 5, to: shop.address})
        await tx.wait()

        const sellAmount = 3;

        const approval = await erc20.connect(buyer).approve(shop.address, sellAmount)

        await approval.wait()

        const sellTx = await shop.connect(buyer).sell(sellAmount)

        expect(await erc20.balanceOf(buyer.address)).to.eq(2)

        await expect(() => sellTx).to.changeEtherBalance(shop, -sellAmount)

        await expect(sellTx).to.emit(shop, "Sold").withArgs(sellAmount, buyer.address)


    })

})