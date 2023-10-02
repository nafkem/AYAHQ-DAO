const hre = require("hardhat");
const helpers = require("@nomicfoundation/hardhat-network-helpers");



async function main() {

    const [deployer, member1, member2, member3] = await ethers.getSigners();

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
  const minimumvote = 2;
  const AyaCommunity = await ethers.deployContract("AyaCommunity", [ayaMembershipToken.target, AyaNFT.target, minimumvote, Ayatoken.target]);
  await AyaCommunity.waitForDeployment();
  console.log(`AyaCommunity deployed to ${AyaCommunity.target}`);

///----------------------INTTERACTION -----------------------------//
const AyatokenInteract = await ethers.getContractAt("Ayatoken", Ayatoken.target);
const AyaNFTInteract = await ethers.getContractAt("AyaNFT", AyaNFT.target);
const ayaMembershipTokenInteract = await ethers.getContractAt("AyaMembershipToken", ayaMembershipToken.target);
const AyaCommunityInteract = await ethers.getContractAt("AyaCommunity", AyaCommunity.target);

const amountTomint = ethers.parseEther("1000");

////MINT Ayatoken
const mintAya = await AyatokenInteract.connect(deployer).mint(AyaCommunity.target, amountTomint);
await mintAya.wait();
console.log(`mintAya  to ${mintAya.hash}`);

//////MINT AyamembershipToken
const mintTx = await ayaMembershipTokenInteract.connect(deployer).mint(member1.address, amountTomint);
              await ayaMembershipTokenInteract.connect(deployer).mint(member3.address, amountTomint);

await mintTx.wait();
console.log(`mintTx  to ${mintTx.hash}`);

//////approve AyamembershipToken
const approveTx = await ayaMembershipTokenInteract.connect(member1).approve(AyaCommunity.target, amountTomint);
                  await ayaMembershipTokenInteract.connect(member3).approve(AyaCommunity.target, amountTomint);
await approveTx.wait();
console.log(`approveTx  to ${approveTx.hash}`);

//////MINT AyaNFT
const mintNFTTx = await AyaNFTInteract.connect(deployer).Mint(member2.address);
await mintNFTTx.wait();
console.log(`mintNFTTx  to ${mintNFTTx.hash}`);

//////approve AyaNFT 
const approveNFTTx = await AyaNFTInteract.connect(member2).approve(AyaCommunity.target, 0);
await approveNFTTx.wait();
console.log(`approveNFTTx   to ${approveNFTTx.hash}`);

///////AyaCommunity interction [becomeMemberWithTokens]
const joinTx = await AyaCommunityInteract.connect(member1).becomeMemberWithTokens();
              await AyaCommunityInteract.connect(member3).becomeMemberWithTokens();
await joinTx.wait();
console.log(`joinTx   to ${joinTx}`);

///////AyaCommunity interction [becomeMemberWithNFT]
const joinTx2 = await AyaCommunityInteract.connect(member2).becomeMemberWithNFT();
await joinTx2.wait();
console.log(`joinTx2   to ${joinTx2}`);

///////AyaCommunity interction [upgradeMembership] revert cos already at the highest level
// const upgradeTx = await AyaCommunityInteract.connect(member2).upgradeMembership();
// await upgradeTx.wait();
// console.log(`upgradeTx   to ${upgradeTx}`);

///////AyaCommunity interction [upgradeMembership]
const upgradeTx2 = await AyaCommunityInteract.connect(member1).upgradeMembership();
await upgradeTx2.wait();
console.log(`upgradeTx2   to ${upgradeTx2}`);


///////AyaCommunity interction [createProposal]
const createProposalTx = await AyaCommunityInteract.connect(member1).createProposal("member1 proposal1");
const createProposalTx2 = await AyaCommunityInteract.connect(member1).createProposal("member1 proposal2");
const createProposalTx3 = await AyaCommunityInteract.connect(member2).createProposal("mmeber2 proposal1");
await createProposalTx.wait();
console.log(`createProposalTx   to ${createProposalTx}`);

///////AyaCommunity interction [vote] //revert cos admin is yet to approve
// const voteTx = await AyaCommunityInteract.connect(member2).vote(0, true);
// await voteTx.wait();
// console.log(`voteTx   to ${voteTx}`);

/////AyaCommunity interction [Deadline]
const proposalDeadlineTx = await AyaCommunityInteract.proposalDeadline();
console.log(`proposal DeadlineTx   to ${proposalDeadlineTx}`);

///////AyaCommunity interction [getProposal]
const getProposalTx = await AyaCommunityInteract.connect(member2).getProposal(0);
console.log(`getProposalTx   to ${ getProposalTx}`);

///////AyaCommunity interction [getUserProposalID]
const getUserProposalIDTx = await AyaCommunityInteract.connect(member2).getUserProposalID(member1.address);
console.log(`getUserProposalIDTx memebr 1 proposal  to ${getUserProposalIDTx}`);

///////AyaCommunity interction [getUserProposalID]
const getUserProposalIDTx2 = await AyaCommunityInteract.connect(member2).getUserProposalID(member2.address);
console.log(`getUserProposalIDTx member 2 proposal  to ${getUserProposalIDTx2}`);

///////AyaCommunity interction [getAllProposal]
const getAllProposalTx = await AyaCommunityInteract.connect(member2).getAllProposals();
console.log(`getAllProposalTx   to ${getAllProposalTx}`);

///////AyaCommunity interction [getAllUserProposal]
const getAllUserProposalTx = await AyaCommunityInteract.connect(member2).getAllUserProposal(member1.address);
console.log(`getAllUserProposalTx all member proposal   to ${getAllUserProposalTx}`);


///////AyaCommunity interction [membershipLevel]
const membershipLevelTx = await AyaCommunityInteract.connect(member2).membershipLevel(member1.address);
console.log(`membershipLevelTx   to ${membershipLevelTx}`);

///////AyaCommunity interction [getAllMembers]
const getAllMembersTx = await AyaCommunityInteract.connect(member2).getAllMembers();
console.log(`getAllMembersTx   to ${getAllMembersTx}`);


/////AyaCommunity interction [getMember]
const getMemberTx = await AyaCommunityInteract.connect(member2).getMemberDetails(member2.address);
console.log(`getMemberTx   to ${getMemberTx}`);

/////AyaCommunity interction [changeProposalState]
const changeProposalStateTx = await AyaCommunityInteract.connect(deployer).changeProposalState(0, true);
await changeProposalStateTx.wait();
console.log(`changeProposalStateTx   to ${changeProposalStateTx}`);


///////AyaCommunity interction [getProposal]
const getProposalTx1 = await AyaCommunityInteract.connect(member2).getProposal(0);
console.log(`getProposalTx  getProposalTx1 to ${ getProposalTx1}`);

//-----------------get curent time------------------//
// console.log(await helpers.time.latest())
// const blockNum = await ethers.provider.getBlockNumber();
// const now = await ethers.provider.getBlock(blockNum);
// console.log(now?.timestamp);


/////AyaCommunity interction [vote] 
const voteTx2 = await AyaCommunityInteract.connect(member1).vote(0, true);
await voteTx2.wait();
console.log(`voteTx2   to ${voteTx2}`);


// /////AyaCommunity interction [executeProposal] //revert because Proposal does not have enough votes
// const executeProposalTx = await AyaCommunityInteract.connect(deployer).executeProposal(0);
// await executeProposalTx.wait();
// console.log(`executeProposalTx   to ${executeProposalTx}`);

/////AyaCommunity interction [vote] 
const voteTx3 = await AyaCommunityInteract.connect(member2).vote(0, true);
await voteTx3.wait();
console.log(`voteTx3   to ${voteTx3}`);

await helpers.time.increaseTo(await helpers.time.latest() + 1209900);


/////AyaCommunity interction [vote] 
const voteTx4 = await AyaCommunityInteract.connect(member3).vote(0, true);
await voteTx4.wait();
console.log(`voteTx4   to ${voteTx4}`);

/////AyaCommunity interction [executeProposal] 
const executeProposalTx = await AyaCommunityInteract.connect(deployer).executeProposal(0);
await executeProposalTx.wait();
console.log(`executeProposalTx   to ${executeProposalTx}`);

/////AyaCommunity interction [getProposalStatus]
const getProposalStatusTx = await AyaCommunityInteract.connect(member2).getProposalStatus(0);
console.log(`getProposalStatusTx   to ${getProposalStatusTx}`);


/////AyaCommunity interction [rewardMember]
const rewardMemberTx = await AyaCommunityInteract.connect(deployer).rewardMember(40, member1.address);
await rewardMemberTx.wait();
console.log(`rewardMemberTx   to ${rewardMemberTx}`);

/////AyaCommunity interction [convertRewardToToken]
const convertRewardToTokenTx = await AyaCommunityInteract.connect(member1).convertRewardToToken();
await convertRewardToTokenTx.wait();
console.log(`convertRewardToTokenTx   to ${convertRewardToTokenTx}`);

/////Ayatoken interaction [balance]
const Ayabalance = await AyatokenInteract.balanceOf(member1.address)
console.log("Ayabalance ", Ayabalance)

/////AyaMembership interaction [balance]
const AyaMembershipBalance = await ayaMembershipTokenInteract.balanceOf(member1.address)
console.log("AyaMembershipBalance ", AyaMembershipBalance)


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});