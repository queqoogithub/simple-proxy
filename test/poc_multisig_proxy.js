const { expect } = require('chai');
 
let Multisig;
let multisig;
let Token;
let token;
 
// Start test block
describe('Multisig (proxy)', function () {
  beforeEach(async function () {
    Token = await ethers.getContractFactory("Token");
    token = await Token.deploy();
    Multisig = await ethers.getContractFactory("SimpleMultisigWallet");
  })

  // Test case
  it('deploy with initialize', async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    multisig = await upgrades.deployProxy(Multisig, [[owner.address, addr1.address, addr2.address], 2], {initializer: 'initialize', unsafeAllow: ['delegatecall']})
    //await multisig.deployed();

    console.log("Multisig address: ", multisig.address)
    console.log("Number of confirmation: ", await multisig.numConfirmationsRequired())
    console.log("Address 2 is owner ?: ", await multisig.isOwner(addr2.address))

    // submit tx
    await multisig.connect(owner).submitSendTokenTx(token.address, addr1.address, 20);

    // check tx count
    const sendingCount = await multisig.getTxCount(1); // getTxCount(1) => 1 is type send token
    console.log('Sending Count just equals 1 = ', sendingCount);
    await multisig.connect(owner).submitSendTokenTx(token.address, addr2.address, 50);
    console.log('Sending Count just equals 2 = ', await multisig.getTxCount(1));

  });
});