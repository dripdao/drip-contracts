'use strict';

const { deployments, upgrades, ethers } = require('hardhat');
const gasnow = require('ethers-gasnow');
ethers.providers.BaseProvider.prototype.getGasPrice = async () => ethers.utils.parseUnits('25', 9);

module.exports = async () => {
  const [ signer ] = await ethers.getSigners();
  const tx = await deployments.deploy('DRIPBOND', {
    contractName: 'DRIPBOND',
    args: [],
    libraries: {},
    from: await signer.getAddress()
  });
};
  
