// scripts/transfer_ownership.js
async function main() {
    const gnosisSafe = '0xf0BfEb8dbdf523118E107F9224A260A40Fe4e428' // Gnosis Safe Address (owner: office1, cat, ...)

    console.log("Transferring ownership of ProxyAdmin...")
    // The owner of the ProxyAdmin can upgrade our contracts
    await upgrades.admin.transferProxyAdminOwnership(gnosisSafe)
    console.log("Transferred ownership of ProxyAdmin to:", gnosisSafe)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })