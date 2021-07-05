import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const HanulCoin = await hardhat.ethers.getContractFactory("HanulCoin")
    const hanulCoin = await HanulCoin.deploy()
    console.log(`HanulCoin address: ${hanulCoin.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
