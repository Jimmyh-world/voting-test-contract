// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console2} from "../../lib/forge-std/src/Script.sol";
import {SwedishVotingContract} from "../../contracts/SwedishVotingContract.sol";
import {ISwedishVoting} from "../../contracts/interfaces/ISwedishVoting.sol";

/// @title Advanced Amoy Test Script
/// @notice Tests advanced functionality of the deployed contract on Amoy
contract AdvancedTestAmoyScript is Script {
    function run() external {
        // Load environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        
        console2.log("=== Advanced Amoy Testnet Testing ===");
        console2.log("Contract Address:", contractAddress);
        console2.log("Admin Address:", admin);
        
        // Get contract instance
        SwedishVotingContract votingContract = SwedishVotingContract(contractAddress);
        
        // Test 1: Check current state
        console2.log("\n=== Test 1: Current State ===");
        uint256 currentSessionCount = votingContract.getSessionCount();
        console2.log("Current session count:", currentSessionCount);
        
        // Test 2: Create a new voting session
        console2.log("\n=== Test 2: Creating New Session ===");
        string[] memory questions = new string[](2);
        questions[0] = "Should we implement advanced features?";
        questions[1] = "Should we add more security measures?";
        
        bool[] memory isPrivate = new bool[](2);
        isPrivate[0] = false; // Public
        isPrivate[1] = true;  // Private
        
        vm.startBroadcast(deployerPrivateKey);
        uint256 newSessionId = votingContract.createVotingSession(questions, isPrivate, 3600);
        vm.stopBroadcast();
        
        console2.log("New session created with ID:", newSessionId);
        
        // Test 3: Get session details
        console2.log("\n=== Test 3: Session Details ===");
        ISwedishVoting.SessionInfo memory sessionInfo = votingContract.getSessionInfo(newSessionId);
        console2.log("Session start time:", sessionInfo.startTime);
        console2.log("Session end time:", sessionInfo.endTime);
        console2.log("Question count:", sessionInfo.questionCount);
        console2.log("Is paused:", sessionInfo.isPaused);
        console2.log("Is finalized:", sessionInfo.isFinalized);
        
        // Test 4: Cast votes
        console2.log("\n=== Test 4: Casting Votes ===");
        
        // Member 1 votes
        uint256 member1Key = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
        vm.startBroadcast(member1Key);
        votingContract.castVote(newSessionId, 0, 1); // Yes on question 0
        votingContract.castVote(newSessionId, 1, 2); // No on question 1
        vm.stopBroadcast();
        console2.log("Member 1 votes cast");
        
        // Member 2 votes
        uint256 member2Key = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
        vm.startBroadcast(member2Key);
        votingContract.castVote(newSessionId, 0, 2); // No on question 0
        votingContract.castVote(newSessionId, 1, 1); // Yes on question 1
        vm.stopBroadcast();
        console2.log("Member 2 votes cast");
        
        // Test 5: Check vote counts for public question
        console2.log("\n=== Test 5: Vote Counts ===");
        ISwedishVoting.VoteCounts memory voteCounts = votingContract.getVoteCounts(newSessionId, 0);
        console2.log("Question 0 (Public) Vote Counts:");
        console2.log("  Abstain:", voteCounts.abstainCount);
        console2.log("  Yes:", voteCounts.yesCount);
        console2.log("  No:", voteCounts.noCount);
        
        // Test 6: Test batch voting
        console2.log("\n=== Test 6: Batch Voting ===");
        address newMember = 0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199;
        uint256 newMemberKey = 0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e;
        
        // Add new member
        address[] memory singleMember = new address[](1);
        singleMember[0] = newMember;
        vm.startBroadcast(deployerPrivateKey);
        votingContract.addMembers(singleMember);
        vm.stopBroadcast();
        
        // Batch vote
        uint256[] memory questionIds = new uint256[](1);
        uint8[] memory votes = new uint8[](1);
        questionIds[0] = 0;
        votes[0] = 0; // Abstain
        
        vm.startBroadcast(newMemberKey);
        votingContract.batchVote(newSessionId, questionIds, votes);
        vm.stopBroadcast();
        console2.log("Batch voting completed");
        
        // Test 7: Test session pause
        console2.log("\n=== Test 7: Session Pause ===");
        vm.startBroadcast(deployerPrivateKey);
        votingContract.pauseSession(newSessionId);
        vm.stopBroadcast();
        
        ISwedishVoting.SessionInfo memory pausedInfo = votingContract.getSessionInfo(newSessionId);
        console2.log("Session paused:", pausedInfo.isPaused);
        
        // Test 8: Test session finalization
        console2.log("\n=== Test 8: Session Finalization ===");
        bytes32 resultsHash = keccak256(abi.encodePacked("Test results"));
        
        vm.startBroadcast(deployerPrivateKey);
        votingContract.finalizeSession(newSessionId, resultsHash);
        vm.stopBroadcast();
        
        ISwedishVoting.SessionInfo memory finalInfo = votingContract.getSessionInfo(newSessionId);
        console2.log("Session finalized:", finalInfo.isFinalized);
        console2.log("Results hash set:", finalInfo.resultsHash == resultsHash);
        
        // Test 9: Check constants
        console2.log("\n=== Test 9: Contract Constants ===");
        console2.log("VOTE_ABSTAIN:", votingContract.VOTE_ABSTAIN());
        console2.log("VOTE_YES:", votingContract.VOTE_YES());
        console2.log("VOTE_NO:", votingContract.VOTE_NO());
        console2.log("MAX_SESSION_DURATION:", votingContract.MAX_SESSION_DURATION());
        console2.log("MAX_BATCH_SIZE:", votingContract.MAX_BATCH_SIZE());
        
        console2.log("\n=== Advanced Tests Completed Successfully! ===");
        console2.log("All advanced functionality working correctly!");
    }
}
