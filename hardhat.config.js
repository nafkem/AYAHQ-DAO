require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
//require("@nomiclabs/hardhat-waffle");
require("dotenv").config();
const { API_URL, PRIVATE_KEY } = process.env;

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
const accounts = await hre.ethers.getSigners();
for (const account of accounts) {
   console.log(account.address);
 }
});
module.exports = {
 solidity: "0.8.19",
 networks: {
  polygon_mumbai: {
    url: "https://rpc-mumbai.maticvigil.com",
    //@ts-ignore
    accounts: [process.env.PRIVATE_KEY]
  }
},
  etherscan: {
  apiKey: process.env.POLYGONSCAN_API_KEY
},
};
