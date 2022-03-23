'use strict';

const { deployments, upgrades, ethers } = require('hardhat');

module.exports = async () => {
  const [ signer ] = await ethers.getSigners();
  const tx = await deployments.deploy('DRIPBONDProxy', {
    contractName: 'DRIPBONDProxy',
    args: [],
    libraries: {},
    from: await signer.getAddress()
  });
};
  
