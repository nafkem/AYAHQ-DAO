// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AyaCommunity is Ownable {
    IERC20 public ayaMembershipToken;
    IERC20 public ayaToken;
    IERC721 public ayaNFT;
    uint256 public minimumVotes;
    uint256 memberId ;
    uint256 public proposalDeadline = 14 days;

    enum MembershipTier { Bronze, Silver, Gold, Diamond }
    enum ProposalStatus { Pending, Denied, Approve, Closed, Executed }
    //enum EngagementLevel { Basic, Increased, High }

    struct Member {
        address memberAddress;
        MembershipTier tier;
        uint256 engagementReward;
        uint256 ayaMembershipTokensOwned;
        uint256 ayaNFTId;
    }
    struct Proposal {
        uint256 proposalId;
        string description;
        uint256 Votes;
        ProposalStatus status;
        uint256 deadline;
    }

    Member[]  members;
    Proposal[]  proposals;
    Proposal[]  executedProposals;
    Proposal[]  deniedProposals;
    Proposal[]  approvedPoposals;
 
    mapping(uint256 => mapping(address => bool)) hasVoted;
    mapping(address => bool) ismember;
    mapping(address => uint256) membermap;
    mapping(address => uint256[]) proposalMap;
    mapping(address => bool) public revoke;
    
    event MemberJoined(address indexed memberAddress, MembershipTier indexed tier);
    event MemberUpgraded(address indexed memberAddress, MembershipTier indexed newTier);
    event MemberVoted(address indexed memberAddress, uint256 indexed proposalId, bool indexed vote);
    event ProposalCreated(uint256 indexed proposalId, string indexed description, address indexed proposer);
    event ProposalClosed(uint256 indexed proposalId, ProposalStatus indexed status, uint256 indexed proposalVotes);
    event ProposalExecuted(uint256 indexed proposalId, ProposalStatus indexed status);
    event Status(uint256 indexed proposalId, ProposalStatus indexed status);
    event TokensTransferred(address indexed recipient, uint256 indexed amount);
    event Donation(address indexed donor, uint256 indexed amount, uint256 indexed timestamp);
    event Revoked(address indexed memberAddress, uint256 indexed timestamp); 
    event VotesUpdated(uint256 indexed minimumVotes, uint256 indexed timestamp);

    modifier isRevoked (){
        require(revoke[msg.sender] == false, "Revoked");
        _;
    }
    

    modifier validAddress(address _memberAddress){
        require(_memberAddress != address(0), "Invalid Address");
        _;
    }

    modifier validAmount(uint256 amount){
        require(amount > 0, "Invalid Amount");
        _;

    }

    modifier validMemebr(){
        require(ismember[msg.sender] == true, "Not a member");
        _;
    }

    modifier validProposal(uint256 _proposalId){
        require(_proposalId < proposals.length, "Invalid proposal ID");
        _;
    }

    constructor(address _ayaMembershipTokenAddress, address _ayaNFTAddress, uint256 _minimumVotes, address _ayaToken) {
        minimumVotes = _minimumVotes;
        ayaMembershipToken = IERC20(_ayaMembershipTokenAddress);
        ayaNFT = IERC721(_ayaNFTAddress);
        ayaToken = IERC20(_ayaToken); 
    }

    //function for community members to become a DAC member
    function becomeMemberWithTokens() external isRevoked{
        require(ismember[msg.sender]== false, "Already a member");

        Member memory member;
        member.memberAddress = msg.sender;
        member.tier = MembershipTier.Bronze;
        member.ayaMembershipTokensOwned = ayaMembershipToken.balanceOf(msg.sender);

        membermap[msg.sender]= memberId;
        ismember[msg.sender]=true;
        members.push(member);
        memberId++;

        emit MemberJoined(msg.sender, MembershipTier.Bronze);
    }

    //Function for core members to become Gold members with NFT
    function becomeMemberWithNFT() external isRevoked{
        require(ayaNFT.balanceOf(msg.sender) >0, "Zero AyaNFT");
        require(ismember[msg.sender]== false, "Already a member");

        Member memory member;
        member.memberAddress = msg.sender;
        member.tier = MembershipTier.Diamond;
        member.ayaNFTId = ayaNFT.balanceOf(msg.sender);

        membermap[msg.sender]= memberId;
        ismember[msg.sender]=true;
        members.push(member);
        memberId++;

        emit MemberJoined(msg.sender, MembershipTier.Bronze);
    }

        // Function to upgrade membership tier
    function upgradeMembership() external isRevoked{
        uint256 memberid = membermap[msg.sender];
        Member storage member = members[memberid];

        require(member.tier != MembershipTier.Diamond, "Already at the highest level");
        require(ayaMembershipToken.balanceOf(msg.sender)>= 1000*1e18, "INSUFFICIENT BALANCE!!!");

        if (ayaMembershipToken.balanceOf(msg.sender)>= 1000*1e18) {
                member.tier = MembershipTier.Silver;
                member.ayaMembershipTokensOwned = ayaMembershipToken.balanceOf(msg.sender);
            }
        else if (ayaMembershipToken.balanceOf(msg.sender) >= 2000*1e18) {
                member.tier = MembershipTier.Gold;
                member.ayaMembershipTokensOwned = ayaMembershipToken.balanceOf(msg.sender);
            }
        else if (ayaMembershipToken.balanceOf(msg.sender) >= 4000*1e18) {
            member.tier = MembershipTier.Diamond;
            member.ayaMembershipTokensOwned = ayaMembershipToken.balanceOf(msg.sender);
        }
        

        emit MemberUpgraded(msg.sender, member.tier);
    }

    //function to create proposal
    function createProposal(string memory _description) external validMemebr {
        uint256 memberid = membermap[msg.sender];
        Member storage member = members[memberid];
        require(member.tier != MembershipTier.Bronze, "UPGRADE MEMBERSHIPTIER TO CREATE PROPOSAL");

        bytes memory strBytes = bytes(_description);
        uint256 proposalId = proposals.length; 
        require(strBytes.length > 0, "Invalid proposal description");
        Proposal memory proposal;
        proposal.description = _description;
        proposal.proposalId = proposalId;
        proposal.status = ProposalStatus.Pending;
        proposals.push(proposal);
        proposalMap[msg.sender].push(proposalId);

        emit ProposalCreated(proposalId, _description, msg.sender);
    }

    //function to Dpprove Proposal or Deny proposal
    //if true = proposal is approved
    //if false = proposal is denied
    function changeProposalState(uint256 _proposalId, bool propoalState) external onlyOwner validProposal(_proposalId){
    Proposal storage proposal = proposals[_proposalId];
    require(proposal.status == ProposalStatus.Pending, "STATUS CHANGED!!");

    if(propoalState == false){
        proposal.status = ProposalStatus.Denied;
        deniedProposals.push(proposal);
    }else{
        proposal.status = ProposalStatus.Approve;
        proposal.deadline = block.timestamp + proposalDeadline;
        approvedPoposals.push(proposal);
        
    }

    emit Status(_proposalId, proposal.status);
    }

    // function to vote
    function vote(uint256 _proposalId, bool _vote) external validProposal(_proposalId) validMemebr isRevoked {
        Proposal storage proposal = proposals[_proposalId];
        require(!hasVoted[_proposalId][msg.sender], "Already voted");
        if(proposal.status == ProposalStatus.Pending){
            revert("PENDING!!!");
        }
        if(proposal.status == ProposalStatus.Denied){
            revert("DENIED!!");
        }
        if(proposal.status == ProposalStatus.Closed){
            revert("CLOSED!!");
        }


        if(block.timestamp < proposal.deadline){
            hasVoted[_proposalId][msg.sender] = true;

            uint256 voteweigth =  membershipLevel(msg.sender);
    
            if (_vote) {
                proposal.Votes += voteweigth;
            } else {
                if ((proposal.Votes -= voteweigth) != 0){
                    proposal.Votes-= voteweigth;
                }
            }

        } else{
            proposal.status = ProposalStatus.Closed;
            hasVoted[_proposalId][msg.sender] = true;
            
            emit ProposalClosed(_proposalId, proposal.status, proposal.Votes);
        }

        emit MemberVoted(msg.sender, _proposalId, _vote);
    }

    function executeProposal(uint256 _proposalId) external onlyOwner validProposal(_proposalId) {
    Proposal storage proposal = proposals[_proposalId];
    if(proposal.status == ProposalStatus.Executed){
        revert("EXECUTED!!!");
    }
    require(proposal.status == ProposalStatus.Closed, "NOT CLOSED");
    require(proposal.Votes >= minimumVotes, "VOTE NOT ENOUGH!");

    proposal.status = ProposalStatus.Executed;
    executedProposals.push(proposal);

    // Perform the actions specified by the proposal

    emit ProposalExecuted(_proposalId, proposal.status);
}


    //function for admin to reward members;
    function rewardMember(uint256 rewardAmount, address _memberAddress) external onlyOwner validAddress(_memberAddress) 
    validAmount(rewardAmount){
        require(ismember[_memberAddress] == true, "Not a member");
        uint256 memberid = membermap[_memberAddress];
        Member storage member = members[memberid];
        member.engagementReward += rewardAmount;
    }

    //convert your reward to Ayatoken
    function convertRewardToToken() external {
        uint256 memberid = membermap[msg.sender];
        Member storage member = members[memberid];
        require(member.engagementReward > 0, "No reward to convert");
        uint256 reward = member.engagementReward;
        // uint256 tokenBalance = ayaToken.balanceOf(address(this));
        // require(tokenBalance >= reward * 1e18, "Insufficient contract balance");
        member.engagementReward = 0;
        ayaToken.transfer(msg.sender, reward*1e18);
    }

    function Donate(uint256 _amount) external validAmount(_amount){
    ayaToken.transferFrom(msg.sender, address(this), _amount);
    emit Donation(msg.sender, _amount, block.timestamp);
}

    function revokeUser(address _memberAddress) external onlyOwner validAddress(_memberAddress) {
    revoke[_memberAddress] = true;
    
    emit Revoked(_memberAddress, block.timestamp);
}

function updateVotes(uint256 _mimimumVotes) external onlyOwner validAmount(_mimimumVotes) {
    minimumVotes = _mimimumVotes;

    emit VotesUpdated(_mimimumVotes, block.timestamp);
}

function updateproposalDeadline(uint256 _proposalDeadline) external onlyOwner validAmount(_proposalDeadline) {
    proposalDeadline = _proposalDeadline;
}

function membershipLevel(address _memberAddress) public view returns(uint256){
    uint256 memberid = membermap[_memberAddress];
    Member memory member = members[memberid];
    uint256 voteweigth;
    if(member.tier == MembershipTier.Bronze){
        voteweigth = 1;
    } else if (member.tier == MembershipTier.Silver){
        voteweigth = 2;
    } else if (member.tier == MembershipTier.Gold){
        voteweigth = 5;
    } else if (member.tier == MembershipTier.Diamond){
        voteweigth = 10;
    }

    return voteweigth;
}

function getMemberDetails(address _memberAddress) public view returns (Member memory) {
    for (uint256 i = 0; i <= members.length; i++) {
        if (members[i].memberAddress == _memberAddress) {
            return members[i];}
    }
        revert("Member not found");    
}


function getMembersCount() external view returns (uint256) {
    return members.length;
}

function getProposalCount() external view returns (uint256) {
    return proposals.length;
}

function getAllProposals() external view returns(Proposal[] memory){
    return proposals;
}

function getAllUserProposal(address _memberAddress) external view validAddress(_memberAddress) returns(Proposal[] memory){
    uint256[] memory allUserProposalIndices = proposalMap[_memberAddress];
    Proposal[] memory userProposals = new Proposal[](allUserProposalIndices.length);

    for (uint256 i = 0; i < allUserProposalIndices.length; i++) {
        uint256 proposalIndex = allUserProposalIndices[i];
        require(proposalIndex < proposals.length, "Invalid proposal index");
        userProposals[i] = proposals[proposalIndex];
    }

    return userProposals;    
}

function getUserProposalID(address _memberAddress) external view validAddress(_memberAddress) returns(uint256[] memory){
    return proposalMap[_memberAddress];
}

function getProposal(uint256 _proposalId) external view returns(Proposal memory){
    return proposals[_proposalId];
   
}

function getProposalStatus(uint256 _proposalId) external view returns(ProposalStatus){
    return proposals[_proposalId].status;
}

function getExecutedProposalCount() external view returns (uint256) {
    return executedProposals.length;
}

function getDeniedProposalCount() external view returns (uint256) {
    return deniedProposals.length;
}

function getAllMembers() external view returns (Member[] memory) {
    return members;
}
}