
exports.getSigner = async (ethers) => {
	const [signer] = await ethers.getSigners.call(ethers);
	return process.env.WALLET ? new ethers.Wallet(process.env.WALLET, signer.provider) : signer;
};
exports.getContract = async (to, ethers) => {
	const deployments = require('hardhat').deployments;
	return await await ethers
		.getContractAt(to, (await deployments.get(to)).address)
		.then((d) => d.address)
		.catch((e) => ethers.utils.getAddress(to));
};

exports.getNetworkId = () => {
	switch (process.env.CHAIN) {
		case 'ARBITRUM':
			return 42161;
		case 'MATIC':
			return 137;
	}
};
