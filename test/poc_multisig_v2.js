const { expect } = require('chai');

// Start test block
describe('PocMultisigV2', function () {
  // Test case
  it('retrieve returns a value previously stored', async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    console.log("Owner[0] address: ", owner.address)
    
    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy();
    const Multisig = await ethers.getContractFactory("SimpleMultisigWalletV2");
    const multisig = await Multisig.deploy();
    await multisig.deployed();

    // initialize instead of constructor
    await multisig.initialize([owner.address, addr1.address, addr2.address], 2);

    console.log("Token address: ", token.address)
    console.log("Multisig deployed to:", multisig.address);

    console.log("Before specify Superowner: ", await multisig.superowner())
    await multisig.specifySuperowner();
    console.log("After specify Superowner: ", await multisig.superowner())
  
    // Store a value
    //await multisig.connect(owner).submitSendTokenTx(token.address, address_2, 20);
    
    // var sendingCount = await multisig.getTxCount(1);
    // console.log('Sending Count just equals 1 = ', sendingCount);
  });
});