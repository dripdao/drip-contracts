'use strict';


const hre = require('hardhat');
const { network: { provider } } = hre;

describe('drip-contracts', () => {
  before(async () => {
    await hre.deployments.fixture();
  });
  it('DRIP.sol', async () => {
    const drip = await hre.ethers.getContract('DRIP');
    await drip.initialize();
  });
  it('DRIPBOND.sol', async () => {
    const drip = new ethers.Contract('0x0d44CfA6a50E4C16eE311af6EDAD36E89f90b0a6', [ 'function permission(address, address, uint256)' ], (await ethers.getSigners())[0])
    const dripMockArtifact = require('../artifacts/contracts/test/DRIPMock.sol/DRIPMock');
    await provider.send('hardhat_setCode', [ethers.utils.getAddress(drip.address), dripMockArtifact.deployedBytecode ]);
    const { address: treasuryAddress } = require('../deployments/mainnet/GnosisSafe');
    const dripBond = await (await hre.ethers.getContractFactory('DRIPBOND')).deploy();
    await drip.permission(treasuryAddress, dripBond.address, ethers.constants.MaxUint256);
    await dripBond.initialize();

    const tx = await dripBond.mint({ value: ethers.utils.parseEther('1') });
  });
});
