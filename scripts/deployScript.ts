import hardhat from "hardhat";

const addresses: { [name: string]: string } = {};

function displayAddress(name: string, address: string) {
    console.log(`- ${name}: ${address}`);
    addresses[name] = address;
}

function showAddressesForJSON() {
    console.log("json");
    for (const [name, address] of Object.entries(addresses)) {
        console.log(`${name}: "${address}",`);
    }
}

async function main() {
    console.log("deploy start")

    const DPlayTradingPost = await hardhat.ethers.getContractFactory("DPlayTradingPost")
    const dplayTradingPost = await DPlayTradingPost.deploy()
    displayAddress("DPlayTradingPost", dplayTradingPost.address)

    const DelightInfo = await hardhat.ethers.getContractFactory("DelightInfo")
    const delightInfo = await DelightInfo.deploy()
    displayAddress("DelightInfo", delightInfo.address)

    // Delight Resources
    const DelightWood = await hardhat.ethers.getContractFactory("DelightWood")
    const delightWood = await DelightWood.deploy(dplayTradingPost.address)
    displayAddress("DelightWood", delightWood.address)

    const DelightStone = await hardhat.ethers.getContractFactory("DelightStone")
    const delightStone = await DelightStone.deploy(dplayTradingPost.address)
    displayAddress("DelightStone", delightStone.address)

    const DelightIron = await hardhat.ethers.getContractFactory("DelightIron")
    const delightIron = await DelightIron.deploy(dplayTradingPost.address)
    displayAddress("DelightIron", delightIron.address)

    const DelightDucat = await hardhat.ethers.getContractFactory("DelightDucat")
    const delightDucat = await DelightDucat.deploy(dplayTradingPost.address)
    displayAddress("DelightDucat", delightDucat.address)

    // Delight Items
    const DelightAxe = await hardhat.ethers.getContractFactory("DelightAxe")
    const delightAxe = await DelightAxe.deploy(dplayTradingPost.address)
    displayAddress("DelightAxe", delightAxe.address)

    const DelightBallista = await hardhat.ethers.getContractFactory("DelightBallista")
    const delightBallista = await DelightBallista.deploy(dplayTradingPost.address)
    displayAddress("DelightBallista", delightBallista.address)

    const DelightCamel = await hardhat.ethers.getContractFactory("DelightCamel")
    const delightCamel = await DelightCamel.deploy(dplayTradingPost.address)
    displayAddress("DelightCamel", delightCamel.address)

    const DelightCatapult = await hardhat.ethers.getContractFactory("DelightCatapult")
    const delightCatapult = await DelightCatapult.deploy(dplayTradingPost.address)
    displayAddress("DelightCatapult", delightCatapult.address)

    const DelightCrossbow = await hardhat.ethers.getContractFactory("DelightCrossbow")
    const delightCrossbow = await DelightCrossbow.deploy(dplayTradingPost.address)
    displayAddress("DelightCrossbow", delightCrossbow.address)

    const DelightElephant = await hardhat.ethers.getContractFactory("DelightElephant")
    const delightElephant = await DelightElephant.deploy(dplayTradingPost.address)
    displayAddress("DelightElephant", delightElephant.address)

    const DelightHood = await hardhat.ethers.getContractFactory("DelightHood")
    const delightHood = await DelightHood.deploy(dplayTradingPost.address)
    displayAddress("DelightHood", delightHood.address)

    const DelightShield = await hardhat.ethers.getContractFactory("DelightShield")
    const delightShield = await DelightShield.deploy(dplayTradingPost.address)
    displayAddress("DelightShield", delightShield.address)

    const DelightSpear = await hardhat.ethers.getContractFactory("DelightSpear")
    const delightSpear = await DelightSpear.deploy(dplayTradingPost.address)
    displayAddress("DelightSpear", delightSpear.address)

    // Delight Knight Item
    const DelightKnightItem = await hardhat.ethers.getContractFactory("DelightKnightItem")
    const delightKnightItem = await DelightKnightItem.deploy(dplayTradingPost.address)
    displayAddress("DelightKnightItem", delightKnightItem.address)

    // Delight Building Manager
    const DelightBuildingManager = await hardhat.ethers.getContractFactory("DelightBuildingManager")
    const delightBuildingManager = await DelightBuildingManager.deploy(
        delightInfo.address,
        delightWood.address,
        delightStone.address,
        delightIron.address,
        delightDucat.address
    )
    displayAddress("DelightBuildingManager", delightBuildingManager.address)

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
    displayAddress("DelightArmyManager", delightArmyManager.address)

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
    displayAddress("DelightItemManager", delightItemManager.address)

    // Delight
    const Delight = await hardhat.ethers.getContractFactory("Delight")
    const delight = await Delight.deploy(
        delightInfo.address,
        delightKnightItem.address,
        delightBuildingManager.address,
        delightArmyManager.address,
        delightItemManager.address
    )
    displayAddress("Delight", delight.address)

    // Delight Owner
    const DelightOwner = await hardhat.ethers.getContractFactory("DelightOwner")
    const delightOwner = await DelightOwner.deploy(
        delight.address,
        delightBuildingManager.address,
        delightArmyManager.address
    )
    displayAddress("DelightOwner", delightOwner.address)

    // Delight Trading Post
    const DelightTradingPost = await hardhat.ethers.getContractFactory("DelightTradingPost")
    const delightTradingPost = await DelightTradingPost.deploy(

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
    displayAddress("DelightTradingPost", delightTradingPost.address)

    // Delight Resource들에 주소 추가
    await delightWood.setDelightBuildingManagerOnce(delightBuildingManager.address);
    await delightWood.setDelightArmyManagerOnce(delightArmyManager.address);
    await delightWood.setDelightItemManagerOnce(delightItemManager.address);

    await delightStone.setDelightBuildingManagerOnce(delightBuildingManager.address);
    await delightStone.setDelightArmyManagerOnce(delightArmyManager.address);
    await delightStone.setDelightItemManagerOnce(delightItemManager.address);

    await delightIron.setDelightBuildingManagerOnce(delightBuildingManager.address);
    await delightIron.setDelightArmyManagerOnce(delightArmyManager.address);
    await delightIron.setDelightItemManagerOnce(delightItemManager.address);

    await delightDucat.setDelightBuildingManagerOnce(delightBuildingManager.address);
    await delightDucat.setDelightArmyManagerOnce(delightArmyManager.address);
    await delightDucat.setDelightItemManagerOnce(delightItemManager.address);

    // Delight Item들에 주소 추가
    await delightAxe.setDelightItemManagerOnce(delightItemManager.address);
    await delightBallista.setDelightItemManagerOnce(delightItemManager.address);
    await delightCamel.setDelightItemManagerOnce(delightItemManager.address);
    await delightCatapult.setDelightItemManagerOnce(delightItemManager.address);
    await delightCrossbow.setDelightItemManagerOnce(delightItemManager.address);
    await delightElephant.setDelightItemManagerOnce(delightItemManager.address);
    await delightHood.setDelightItemManagerOnce(delightItemManager.address);
    await delightShield.setDelightItemManagerOnce(delightItemManager.address);
    await delightSpear.setDelightItemManagerOnce(delightItemManager.address);

    // Delight Knight Item에 주소 추가
    await delightKnightItem.setDelightItemManagerOnce(delightItemManager.address);

    // Delight Building Manager에 주소 추가
    await delightBuildingManager.setDelightOnce(delight.address);
    await delightBuildingManager.setDelightArmyManagerOnce(delightArmyManager.address);
    await delightBuildingManager.setDelightItemManagerOnce(delightItemManager.address);

    // Delight Army Manager에 주소 추가
    await delightArmyManager.setDelightOnce(delight.address);
    await delightArmyManager.setDelightBuildingManagerOnce(delightBuildingManager.address);
    await delightArmyManager.setDelightItemManagerOnce(delightItemManager.address);

    // Delight Item Manager에 주소 추가
    await delightItemManager.setDelightOnce(delight.address);
    await delightItemManager.setDelightArmyManagerOnce(delightArmyManager.address);

    showAddressesForJSON();
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
