'use strict';


const hre = require('hardhat');

describe('drip-contracts', () => {
  before(async () => {
    await hre.deployments.fixture();
  });
  it('DRIP.sol', async () => {
    const drip = await hre.ethers.getContract('DRIP');
    await drip.initialize();
  });
});
