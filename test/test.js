'use strict';


const hre = require('hardhat');
const { network: { provider } } = hre;

describe('drip-contracts', () => {
  before(async () => {
    await hre.deployments.fixture();
  });
  it('DRIPBOND.sol', async () => {
    const [ signer ] = await ethers.getSigners();
    const drip = new ethers.Contract('0x0d44CfA6a50E4C16eE311af6EDAD36E89f90b0a6', [ 'function balanceOf(address) view returns (uint256)', 'function permission(address, address, uint256)' ], signer);
    const dripMockArtifact = require('../artifacts/contracts/test/DRIPMock.sol/DRIPMock');
    await provider.send('hardhat_setCode', [ethers.utils.getAddress(drip.address), dripMockArtifact.deployedBytecode ]);
    const { address: treasuryAddress } = require('../deployments/mainnet/GnosisSafe');
    const dripBondProxy = await (await hre.ethers.getContractFactory('DRIPBONDProxy')).deploy();
    const dripBond = new ethers.Contract(dripBondProxy.address, [ 'function mint() payable returns (uint256)', 'function burn(uint256)' ], dripBondProxy.signer);
    await drip.permission(treasuryAddress, dripBond.address, ethers.constants.MaxUint256);
//    await dripBond.initialize();

    const tx = await dripBond.mint({ value: ethers.utils.parseEther('1') });
    await provider.send('evm_setNextBlockTimestamp', [Math.floor(Date.now() / 1000) + 60*60*24*60]);
    await provider.send('evm_mine');
    await dripBond.burn(0);
    console.log(ethers.utils.formatEther(await drip.balanceOf(await signer.getAddress())));
  });
});
