// scripts/prepare_upgrade.js
async function main() {
    const proxyAddress = '0x5ae338D1626B9b0081AFA2EAcB0544063e780538' // owner: office1
    const BoxV2 = await ethers.getContractFactory("BoxV2")
    console.log("Preparing upgrade...")
    const boxV2Address = await upgrades.prepareUpgrade(proxyAddress, BoxV2)
    console.log("BoxV2 at:", boxV2Address)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })