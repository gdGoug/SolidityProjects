
const hre = require('hardhat');
const ethers = hre.ethers;
const fs = require('fs');
const path = require('path');



async function main() {
    if(hre.network.name = "hardhat"){
        console.warn("You are trying to deply a constract to the Hardhat NetWork, which gets automatically created and destroyed every time.");

    }

    const [deployer] = await ethers.getSigners()

    console.log("Deploying with", await deployer.getAddress())

    const DutchAuction = await ethers.getContractFactory("AucEngine", deployer)
    const auction = await DutchAuction.deploy()
    await auction.deployed()

    saveFrontedFiles({
        AucEngine: auction
    })



}

function saveFrontedFiles(contracts){
    const contractsDir = path.join(__dirname, '/..', 'front/contracts')

    if(!fs.existsSync(contractsDir)){
        fs.mkdirSync(contractsDir)
    }

    Object.entries(contracts).forEach((contract_item) =>  {
        const[name, constract] = contract_item

        if(constract){
            fs.writeFileSync(
                path.join(contractsDir, '/', name + '-contract-address.json'),
                JSON.stringify({[name]: constract.address}, undefined, 2)
            )

        }

        const ContractArtifact = hre.artifacts.readArtifactSync(name)
        fs.writeFileSync(
            path.join(contractsDir, '/', name + ".json"),
            JSON.stringify(ContractArtifact, null, 2)
        )
    })
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
