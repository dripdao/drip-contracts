require("hardhat-deploy");
require("hardhat-deploy-ethers");
require("@openzeppelin/hardhat-upgrades");
require("hardhat-gas-reporter");
require("@nomiclabs/hardhat-etherscan");
const ethers = require("ethers");

const RPC_ENDPOINTS = {
  ETHEREUM: "https://mainnet.infura.io/v3/816df2901a454b18b7df259e61f92cd2",
};

const ETHERSCAN_API_KEYS = {
  ETHEREUM: "34W9GX5VZDJKJKVV6YEAMQ3TDP7R8SR633",
};

const accounts = [
  process.env.WALLET || ethers.Wallet.createRandom().privateKey,
];

module.exports = {
  gasReporter: {
    enabled: true,
  },
  solidity: {
    compilers: [
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      forking: {
        enabled: true,
        url: RPC_ENDPOINTS.ETHEREUM,
      },
    },
    mainnet: {
      url: RPC_ENDPOINTS.ETHEREUM,
      accounts,
      chainId: 1,
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEYS.ETHEREUM,
  },
};
