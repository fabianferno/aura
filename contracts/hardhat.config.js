require("@nomicfoundation/hardhat-toolbox");
// require("@nomiclabs/hardhat-etherscan");
// require("@nomicfoundation/hardhat-verify");

require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY],
    },
    optimismSepolia: {
      url: `https://opt-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY],
    },
    openCampusCodex: {
      url: "https://rpc.open-campus-codex.gelato.digital",
      chainId: 656476,
      accounts: [process.env.PRIVATE_KEY],
    },
    morphl2: {
      url: "https://rpc-quicknode-holesky.morphl2.io",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      // gasprice: 2000000000,
    },
  },
  // etherscan: {
  //   apiKey: {
  //     sepolia: process.env.ETHERSCAN_API_KEY,
  //     openCampusCodex: process.env.OPENCAMPUS_CODEX_API_KEY,
  //   },
  //   customChains: [
  //     {
  //       network: "openCampusCodex",
  //       chainId: 656476,
  //       urls: {
  //         apiURL: "https://opencampus-codex.blockscout.com/api",
  //         browserURL: "https://opencampus-codex.blockscout.com",
  //       },
  //     },
  //   ],
  // },
};
