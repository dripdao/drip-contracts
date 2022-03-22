var ethers = require('ethers');

var wallet = new ethers.Wallet(process.env.DRIP_WALLET).connect(new ethers.providers.InfuraProvider('mainnet'));

var drip = new ethers.Contract('0x0d44CfA6a50E4C16eE311af6EDAD36E89f90b0a6', [ 'function balanceOf(address) view returns (uint256)', 'function initialize()'], wallet);

var proxyAdmin = new ethers.Contract('0xEBfE0Fd21208DC2e1321ACeFeE93904Ba8AEf743', [ 'function upgradeAndCall(address, address, bytes)' ], wallet);
