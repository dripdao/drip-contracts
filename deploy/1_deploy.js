'use strict';

const { deployments, upgrades, ethers } = require('hardhat');
const gasnow = require('ethers-gasnow');
ethers.providers.BaseProvider.prototype.getGasPrice = async () => ethers.utils.parseUnits('16', 9);

module.exports = async () => {
  const [ signer ] = await ethers.getSigners();
  const tx = await deployments.deploy('DRIP', {
    contractName: 'DRIP',
    args: [],
    libraries: {},
    from: await signer.getAddress()
  });
};
  
