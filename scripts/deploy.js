const hre = require("hardhat");
async function main() {

 //Aya Token Deployment
 const Ayatoken = await ethers.deployContract("Ayatoken");
 await Ayatoken.waitForDeployment();
 console.log(`Ayatoken  deployed to ${Ayatoken.target}`);

 //Aya NFT Deployment
 const AyaNFT = await ethers.deployContract("AyaNFT");
 await AyaNFT.waitForDeployment();
 console.log(`AyaNFT  deployed to ${AyaNFT.target}`);

 //Aya Membership Token Deployment
 const ayaMembershipToken = await ethers.deployContract("AyaMembershipToken");
 await ayaMembershipToken.waitForDeployment();
 console.log(`ayaMembershipToken  deployed to ${ayaMembershipToken.target}`);

//DEPLOY AyaCommunity
 const AyaCommunity = await ethers.deployContract("AyaCommunity", [ayaMembershipToken.target, AyaNFT.target, 100, Ayatoken.target]);
 await AyaCommunity.waitForDeployment();
 console.log(`AyaCommunity deployed to ${AyaCommunity.target}`);

}
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  





























//  const AyaNFT= await hre.ethers.getContractFactory("AyaNFT");
//  const ayaNFT= await AyaNFT.deploy();
//       await ayaNFT.deployed();
//   console.log(
//     `AyaNFT deployed to ${AyaNFT.address}`
//   );
//   const AyaToken= await hre.ethers.getContractFactory("AyaToken");
//   const ayaToken= await AyaToken.deploy();
//       await AyaToken.deployed();
//   console.log(
//     `AyaToken deployed to ${AyaToken.address}`
//   );
//   const AyaCommunity= await hre.ethers.getContractFactory("AyaCommunity");
//   const ayaCommunity= await AyaCommunity.deploy(AyaNFT, AyaToken,2);
//       await ayaCommunity.deployed();
//   console.log(
//     `AyaCommunity deployed to ${AyaCommunity.address}`
//   );
//}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
