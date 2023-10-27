
require('@nomicfoundation/hardhat-toolbox');
require("dotenv").config({ path: ".env" });

module.exports = {
  solidity: "0.8.17",
  networks: {
    // for testnet
    'base-goerli': {
      url: 'https://goerli.base.org',
      accounts: [process.env.PRIVATE_KEY]
      //gasPrice: 1000000000,
    },
  },
  };
