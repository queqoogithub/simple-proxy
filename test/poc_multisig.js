const { expect } = require('chai');

// Start test block
describe('PocMultisig', function () {
//   beforeEach(async function () {
//     const address_1 = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";
//     const address_2 = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC";
//     const address_3 = "0x90F79bf6EB2c4f870365E785982E1f101E93b906";
    
//     const Multisig = await ethers.getContractFactory("PocMultisig");
//     //const multisig = await Multisig.deploy([address_1.address, address_2.address, address_3.address], 2);
//     const multisig = await upgrades.deployProxy(Multisig, { constructorArgs: ([address_1.address, address_2.address, address_3.address], 2) })
//     await multisig.deployed();

//     console.log("Multisig deployed to:", multisig.address);
//   });
 
  // Test case
  it('retrieve returns a value previously stored', async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    //console.log("Owner : ", owner)
    //console.log("Owner address: ", owner.address)
    
    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy();
    const Multisig = await ethers.getContractFactory("SimpleMultisigWallet");
    const multisig = await Multisig.deploy();
    await multisig.deployed();

    // initialize instead of constructor
    await multisig.initialize([owner.address, addr1.address, addr2.address], 2);

    console.log("Token address: ", token.address)
    console.log("Multisig deployed to:", multisig.address);
  
    // Store a value
    //await multisig.connect(owner).submitSendTokenTx(token.address, address_2, 20);
    
    // var sendingCount = await multisig.getTxCount(1);
    // console.log('Sending Count just equals 1 = ', sendingCount);
  });
});