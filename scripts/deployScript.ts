import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const DPlayTradingPost = await hardhat.ethers.getContractFactory("DPlayTradingPost")
    const dplayTradingPost = await DPlayTradingPost.deploy()
    console.log(`DPlayTradingPost address: ${dplayTradingPost.address}`)

    const DelightInfo = await hardhat.ethers.getContractFactory("DelightInfo")
    const delightInfo = await DelightInfo.deploy()
    console.log(`DelightInfo address: ${delightInfo.address}`)

    // Delight Resources
    const DelightWood = await hardhat.ethers.getContractFactory("DelightWood")
    const delightWood = await DelightWood.deploy()
    console.log(`DelightWood address: ${delightWood.address}`)
    
    const DelightStone = await hardhat.ethers.getContractFactory("DelightStone")
    const delightStone = await DelightStone.deploy()
    console.log(`DelightStone address: ${delightStone.address}`)
    
    const DelightIron = await hardhat.ethers.getContractFactory("DelightIron")
    const delightIron = await DelightIron.deploy()
    console.log(`DelightIron address: ${delightIron.address}`)
    
    const DelightDucat = await hardhat.ethers.getContractFactory("DelightDucat")
    const delightDucat = await DelightDucat.deploy()
    console.log(`DelightDucat address: ${delightDucat.address}`)

    // Delight Items
    const DelightAxe = await hardhat.ethers.getContractFactory("DelightAxe")
    const delightAxe = await DelightAxe.deploy(dplayTradingPost.address)
    console.log(`DelightAxe address: ${delightAxe.address}`)
    
    const DelightBallista = await hardhat.ethers.getContractFactory("DelightBallista")
    const delightBallista = await DelightBallista.deploy(dplayTradingPost.address)
    console.log(`DelightBallista address: ${delightBallista.address}`)
    
    const DelightCamel = await hardhat.ethers.getContractFactory("DelightCamel")
    const delightCamel = await DelightCamel.deploy(dplayTradingPost.address)
    console.log(`DelightCamel address: ${delightCamel.address}`)
    
    const DelightCatapult = await hardhat.ethers.getContractFactory("DelightCatapult")
    const delightCatapult = await DelightCatapult.deploy(dplayTradingPost.address)
    console.log(`DelightCatapult address: ${delightCatapult.address}`)
    
    const DelightCrossbow = await hardhat.ethers.getContractFactory("DelightCrossbow")
    const delightCrossbow = await DelightCrossbow.deploy(dplayTradingPost.address)
    console.log(`DelightCrossbow address: ${delightCrossbow.address}`)
    
    const DelightElephant = await hardhat.ethers.getContractFactory("DelightElephant")
    const delightElephant = await DelightElephant.deploy(dplayTradingPost.address)
    console.log(`DelightElephant address: ${delightElephant.address}`)
    
    const DelightHood = await hardhat.ethers.getContractFactory("DelightHood")
    const delightHood = await DelightHood.deploy(dplayTradingPost.address)
    console.log(`DelightHood address: ${delightHood.address}`)
    
    const DelightShield = await hardhat.ethers.getContractFactory("DelightShield")
    const delightShield = await DelightShield.deploy(dplayTradingPost.address)
    console.log(`DelightShield address: ${delightShield.address}`)
    
    const DelightSpear = await hardhat.ethers.getContractFactory("DelightSpear")
    const delightSpear = await DelightSpear.deploy(dplayTradingPost.address)
    console.log(`DelightSpear address: ${delightSpear.address}`)

    // Delight Knight Item
    const DelightKnightItem = await hardhat.ethers.getContractFactory("DelightKnightItem")
    const delightKnightItem = await DelightKnightItem.deploy(dplayTradingPost.address)
    console.log(`DelightKnightItem address: ${delightKnightItem.address}`)
    
    // Delight Building Manager
    const DelightBuildingManager = await hardhat.ethers.getContractFactory("DelightBuildingManager")
    const delightBuildingManager = await DelightBuildingManager.deploy(
        delightInfo.address,
        delightWood.address,
        delightStone.address,
        delightIron.address,
        delightDucat.address
    )
    console.log(`DelightBuildingManager address: ${delightBuildingManager.address}`)
    
    // Delight Army Manager
    const DelightArmyManager = await hardhat.ethers.getContractFactory("DelightArmyManager")
    const delightArmyManager = await DelightArmyManager.deploy(
        delightInfo.address,
        delightWood.address,
        delightStone.address,
        delightIron.address,
        delightDucat.address,
        delightKnightItem.address
    )
    console.log(`DelightArmyManager address: ${delightArmyManager.address}`)
    
    // Delight Item Manager
    const DelightItemManager = await hardhat.ethers.getContractFactory("DelightItemManager")
    const delightItemManager = await DelightItemManager.deploy(
        
		delightInfo.address,
		delightWood.address,
		delightStone.address,
		delightIron.address,
		delightDucat.address,

		delightAxe.address,
		delightBallista.address,
		delightCamel.address,
		delightCatapult.address,
		delightCrossbow.address,
		delightElephant.address,
		delightHood.address,
		delightShield.address,
		delightSpear.address,

		delightKnightItem.address
    )
    console.log(`DelightItemManager address: ${delightItemManager.address}`)
    
    // Delight
    const Delight = await hardhat.ethers.getContractFactory("Delight")
    const delight = await Delight.deploy(
		delightInfo.address,
		delightKnightItem.address,
		delightBuildingManager.address,
		delightArmyManager.address,
		delightItemManager.address
    )
    console.log(`Delight address: ${delight.address}`)
    
    // Delight Owner
    const DelightOwner = await hardhat.ethers.getContractFactory("DelightOwner")
    const delightOwner = await DelightOwner.deploy(
		delight.address,
		delightBuildingManager.address,
		delightArmyManager.address
    )
    console.log(`DelightOwner address: ${delightOwner.address}`)
    
    // Delight Trading Post
    const DelightTradingPost = await hardhat.ethers.getContractFactory("DelightTradingPost")
    const delightTradingPost = await DelightTradingPost.deploy(
        
		delightInfo.address,
		delightWood.address,
		delightStone.address,
		delightIron.address,
		delightDucat.address,

		delightAxe.address,
		delightBallista.address,
		delightCamel.address,
		delightCatapult.address,
		delightCrossbow.address,
		delightElephant.address,
		delightHood.address,
		delightShield.address,
		delightSpear.address,

		delightKnightItem.address,
        dplayTradingPost.address
    )
    console.log(`DelightTradingPost address: ${delightTradingPost.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
