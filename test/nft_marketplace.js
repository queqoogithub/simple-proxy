// test/Box.js
// Load dependencies
const { expect } = require('chai');

let Market;
let market;

// Start test block
describe('Market', function () {
  beforeEach(async function () {
    Market = await ethers.getContractFactory("NFTMarketplace");
    market = await Market.deploy();
    await market.deployed();

    console.log("NFT Marketplace deployed to:", market.address);
  });
 
  // Test case
  it('retrieve returns a value previously stored', async function () {
    // Store a value
    const owner = await market.marketowner();
 
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    console.log('Owner: ', owner);
  });
});