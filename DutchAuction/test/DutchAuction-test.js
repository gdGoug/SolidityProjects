const {expect} = require("chai")
const {ethers} = require("hardhat")

describe("DutchAuction", function(){
    let owner 
    let seller
    let buyer 
    let auct 
    
    beforeEach(async function (){
        [owner, seller, buyer] = await ethers.getSigners()

        const AuctEngine = await ethers.getContractFactory("AucEngine", owner)
        auct = await AuctEngine.deploy()
        await auct.deployed()
    })

    it("sets owner", async function(){
        const currentOwner = await auct.owner()
        console.log(currentOwner)
        expect(currentOwner).to.eq(owner.address)
    })

    async function getTimestamp(bn){
        return(
            await ethers.provider.getBlock(bn)
        ).timestamp
    }

    describe("createAuction", function(){
        it("creates auction correctly", async function(){
            const duration = 60
            const tx = await auct.createAuction(
                ethers.utils.parseEther("0.01"),
                3,
                "My item",
                duration
            )

            const cAuction = await auct.auctions(0)
            console.log(cAuction)
            expect(cAuction.item).to.eq("My item")
            const ts = await getTimestamp(tx.blockNumber)
            expect(cAuction.endsAt).to.eq(ts + duration)
        })
    })

    function delay(ms){
        return new Promise(resolve =>setTimeout(resolve,ms))
    }

    describe("buy", function(){
        it("allows to buy", async function(){
            await auct.connect(seller).createAuction(
                ethers.utils.parseEther("0.0001"),
                3,
                "My item",
                60
            )

            this.timeout(5000)
            await delay (1000)

            const buyTx = await auct.connect(buyer).buy(0, {value: ethers.utils.parseEther("0.0001")})


            const cAuction = await auct.auctions(0)
            const finalPrice = cAuction.finalPrice
            await expect(() => buyTx).to.changeEtherBalance(seller, finalPrice - Math.floor((finalPrice * 5) / 100))

            await expect(buyTx).to.emit(auct, 'AuctionEnded').withArgs(0,finalPrice, buyer.address)

            await expect(auct.connect(buyer).
                buy(0, {value: ethers.utils.parseEther("0.0001")})).to.be.revertedWith('stopped!')
        })
    })
})