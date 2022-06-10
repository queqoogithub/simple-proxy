const { expect } = require('chai');
 
let Multisig;
let multisig;
let MultisigV2;
let multisigV2;
let Token;
let token;
 
// Start test block
describe('MultisigV2 (proxy)', function () {
  beforeEach(async function () {
    Token = await ethers.getContractFactory("Token");
    token = await Token.deploy();
    Multisig = await ethers.getContractFactory("SimpleMultisigWallet");
    MultisigV2 = await ethers.getContractFactory("SimpleMultisigWalletV2");
  })

  // Test case
  it('deploy with initialize', async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    multisig = await upgrades.deployProxy(Multisig, [[owner.address, addr1.address, addr2.address], 2], {initializer: 'initialize', unsafeAllow: ['delegatecall']})
    //await multisig.deployed();
    multisigV2 = await upgrades.upgradeProxy(multisig.address, MultisigV2, {unsafeAllow: ['delegatecall']});

    console.log("MultisigV1 address: ", multisig.address)
    console.log("MultisigV2 address: ", multisigV2.address)
    console.log("Number of confirmation: ", await multisigV2.numConfirmationsRequired())
    console.log("Address 2 is owner ?: ", await multisigV2.isOwner(addr2.address))

    // submit tx
    await multisigV2.connect(owner).submitSendTokenTx(token.address, addr1.address, 20);

    // check tx count
    const sendingCount = await multisigV2.getTxCount(1); // getTxCount(1) => 1 is type send token
    console.log('Sending Count just equals 1 = ', sendingCount);
    await multisigV2.connect(owner).submitSendTokenTx(token.address, addr2.address, 50);
    console.log('Sending Count just equals 2 = ', await multisigV2.getTxCount(1));

    // check superowner 
    console.log("Owner[0]: ", owner.address)
    console.log("Before specify Superowner: ", await multisigV2.superowner())
    await multisigV2.specifySuperowner();
    console.log("After specify Superowner with Owner[0]: ", await multisigV2.superowner())

  });
});