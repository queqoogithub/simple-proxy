const { expect } = require('chai');
 
let Multisig;
let multisig;
let Token;
let token;
 
// Start test block
describe('Multisig (proxy)', function () {
//   beforeEach(async function () {
//     const [owner, addr1, addr2] = await ethers.getSigners();
//     Token = await ethers.getContractFactory("Token");
//     token = await Token.deploy();
//     Multisig = await ethers.getContractFactory("SimpleMultisigWallet");
//     //multisig = await Multisig.deploy([owner.address, address_2, address_3], 2);
//     multisig = await upgrades.deployProxy(Multisig, { constructorArgs: ([owner.address, addr1.address, addr2.address], 2) })
//     await multisig.deployed();
//   });
 
  // Test case
  it('retrieve returns a value previously initialized', async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    Token = await ethers.getContractFactory("Token");
    token = await Token.deploy();
    Multisig = await ethers.getContractFactory("SimpleMultisigWallet");
    //multisig = await Multisig.deploy([owner.address, address_2, address_3], 2);
    multisig = await upgrades.deployProxy(Multisig, { constructorArgs: ([owner.address, addr1.address, addr2.address], 2) })
    await multisig.deployed();

    
    await multisig.connect(owner).submitSendTokenTx(token.address, address_2, 20);
    // Todo ... another test case
  });
});