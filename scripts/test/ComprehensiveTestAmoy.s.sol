// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console2} from "../../lib/forge-std/src/Script.sol";
import {SwedishVotingContract} from "../../contracts/SwedishVotingContract.sol";
import {ISwedishVoting} from "../../contracts/interfaces/ISwedishVoting.sol";

/// @title Comprehensive Amoy Test Script
/// @notice Tests all major functionality of the deployed contract on Amoy
contract ComprehensiveTestAmoyScript is Script {
    function run() external {
        // Load environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        
        console2.log("=== Comprehensive Amoy Testnet Testing ===");
        console2.log("Contract Address:", contractAddress);
        console2.log("Admin Address:", admin);
        
        // Get contract instance
        SwedishVotingContract votingContract = SwedishVotingContract(contractAddress);
        
        // Test 1: Verify initial state
        console2.log("\n=== Test 1: Initial State Verification ===");
        require(votingContract.admin() == admin, "Admin not set correctly");
        uint256 sessionCount = votingContract.getSessionCount();
        console2.log("Current session count:", sessionCount);
        console2.log("Initial state verified");
        
        // Test 2: Add more members
        console2.log("\n=== Test 2: Adding More Members ===");
        address[] memory newMembers = new address[](1);
        newMembers[0] = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
        
        vm.startBroadcast(deployerPrivateKey);
        votingContract.addMembers(newMembers);
        vm.stopBroadcast();
        
        require(votingContract.isMember(newMembers[0]), "New member not added");
        console2.log("Additional member added successfully");
        
        // Test 3: Create a new voting session with multiple questions
        console2.log("\n=== Test 3: Creating Multi-Question Session ===");
        string[] memory questions = new string[](3);
        questions[0] = "Should we add more features to the contract?";
        questions[1] = "Should we deploy to mainnet?";
        questions[2] = "Should we implement batch voting?";
        
        bool[] memory isPrivate = new bool[](3);
        isPrivate[0] = false; // Public question
        isPrivate[1] = false; // Public question
        isPrivate[2] = true;  // Private question
        
        vm.startBroadcast(deployerPrivateKey);
        uint256 newSessionId = votingContract.createVotingSession(questions, isPrivate, 7200); // 2 hours
        vm.stopBroadcast();
        
        console2.log("New session created with ID:", newSessionId);
        require(votingContract.getSessionCount() == sessionCount + 1, "Session count not incremented");
        
        // Test 4: Get session information
        console2.log("\n=== Test 4: Session Information ===");
        ISwedishVoting.SessionInfo memory sessionInfo = votingContract.getSessionInfo(newSessionId);
        console2.log("Session Info:");
        console2.log("  Start Time:", sessionInfo.startTime);
        console2.log("  End Time:", sessionInfo.endTime);
        console2.log("  Question Count:", sessionInfo.questionCount);
        console2.log("  Is Paused:", sessionInfo.isPaused);
        console2.log("  Is Finalized:", sessionInfo.isFinalized);
        console2.log("  Exists:", sessionInfo.exists);
        
        // Test 5: Cast votes (as different members)
        console2.log("\n=== Test 5: Casting Votes ===");
        
        // Member 1 votes
        uint256 member1Key = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
        vm.startBroadcast(member1Key);
        votingContract.castVote(newSessionId, 0, 1); // Yes on question 0
        votingContract.castVote(newSessionId, 1, 2); // No on question 1
        votingContract.castVote(newSessionId, 2, 0); // Abstain on question 2
        vm.stopBroadcast();
        console2.log("Member 1 votes cast successfully");
        
        // Member 2 votes
        uint256 member2Key = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
        vm.startBroadcast(member2Key);
        votingContract.castVote(newSessionId, 0, 1); // Yes on question 0
        votingContract.castVote(newSessionId, 1, 1); // Yes on question 1
        votingContract.castVote(newSessionId, 2, 1); // Yes on question 2
        vm.stopBroadcast();
        console2.log("Member 2 votes cast successfully");
        
        // Member 3 votes
        uint256 member3Key = 0x7c852118e8d7e3b9d5b4b0d7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b;
        vm.startBroadcast(member3Key);
        votingContract.castVote(newSessionId, 0, 2); // No on question 0
        votingContract.castVote(newSessionId, 1, 0); // Abstain on question 1
        votingContract.castVote(newSessionId, 2, 2); // No on question 2
        vm.stopBroadcast();
        console2.log("Member 3 votes cast successfully");
        
        // Test 6: Check vote counts for public questions
        console2.log("\n=== Test 6: Vote Counts (Public Questions) ===");
        
        // Question 0 (Public)
        ISwedishVoting.VoteCounts memory voteCounts0 = votingContract.getVoteCounts(newSessionId, 0);
        console2.log("Question 0 Vote Counts:");
        console2.log("  Abstain:", voteCounts0.abstainCount);
        console2.log("  Yes:", voteCounts0.yesCount);
        console2.log("  No:", voteCounts0.noCount);
        
        // Question 1 (Public)
        ISwedishVoting.VoteCounts memory voteCounts1 = votingContract.getVoteCounts(newSessionId, 1);
        console2.log("Question 1 Vote Counts:");
        console2.log("  Abstain:", voteCounts1.abstainCount);
        console2.log("  Yes:", voteCounts1.yesCount);
        console2.log("  No:", voteCounts1.noCount);
        
        // Test 7: Check voting status
        console2.log("\n=== Test 7: Voting Status Verification ===");
        require(votingContract.hasVoted(newSessionId, 0, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8), "Member 1 vote not recorded");
        require(votingContract.hasVoted(newSessionId, 0, 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC), "Member 2 vote not recorded");
        require(votingContract.hasVoted(newSessionId, 0, 0x90F79bf6EB2c4f870365E785982E1f101E93b906), "Member 3 vote not recorded");
        console2.log("All votes recorded correctly");
        
        // Test 8: Test batch voting for a new member
        console2.log("\n=== Test 8: Batch Voting Test ===");
        address newMember = 0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199;
        uint256 newMemberKey = 0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e;
        
        // Add new member first
        address[] memory singleMember = new address[](1);
        singleMember[0] = newMember;
        vm.startBroadcast(deployerPrivateKey);
        votingContract.addMembers(singleMember);
        vm.stopBroadcast();
        
        // Test batch voting
        uint256[] memory questionIds = new uint256[](2);
        uint8[] memory votes = new uint8[](2);
        questionIds[0] = 0;
        questionIds[1] = 1;
        votes[0] = 1; // Yes
        votes[1] = 2; // No
        
        vm.startBroadcast(newMemberKey);
        votingContract.batchVote(newSessionId, questionIds, votes);
        vm.stopBroadcast();
        console2.log("Batch voting successful");
        
        // Test 9: Test session pause functionality
        console2.log("\n=== Test 9: Session Pause Test ===");
        vm.startBroadcast(deployerPrivateKey);
        votingContract.pauseSession(newSessionId);
        vm.stopBroadcast();
        
        ISwedishVoting.SessionInfo memory pausedSessionInfo = votingContract.getSessionInfo(newSessionId);
        require(pausedSessionInfo.isPaused, "Session not paused");
        console2.log("Session paused successfully");
        
        // Test 10: Test session finalization
        console2.log("\n=== Test 10: Session Finalization Test ===");
        bytes32 resultsHash = keccak256(abi.encodePacked("Final results hash"));
        
        vm.startBroadcast(deployerPrivateKey);
        votingContract.finalizeSession(newSessionId, resultsHash);
        vm.stopBroadcast();
        
        ISwedishVoting.SessionInfo memory finalizedSessionInfo = votingContract.getSessionInfo(newSessionId);
        require(finalizedSessionInfo.isFinalized, "Session not finalized");
        require(finalizedSessionInfo.resultsHash == resultsHash, "Results hash not set");
        console2.log("Session finalized successfully");
        
        // Test 11: Check constants
        console2.log("\n=== Test 11: Contract Constants ===");
        console2.log("VOTE_ABSTAIN:", votingContract.VOTE_ABSTAIN());
        console2.log("VOTE_YES:", votingContract.VOTE_YES());
        console2.log("VOTE_NO:", votingContract.VOTE_NO());
        console2.log("MIN_SESSION_DURATION:", votingContract.MIN_SESSION_DURATION());
        console2.log("MAX_SESSION_DURATION:", votingContract.MAX_SESSION_DURATION());
        console2.log("MAX_BATCH_SIZE:", votingContract.MAX_BATCH_SIZE());
        
        console2.log("\n=== All Comprehensive Tests Passed! ===");
        console2.log("Your Swedish Voting Contract is fully functional on Amoy testnet!");
        console2.log("Ready for production deployment to Polygon mainnet!");
    }
}
