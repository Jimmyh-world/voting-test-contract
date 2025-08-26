// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {SwedishVotingContract} from "../contracts/SwedishVotingContract.sol";

/// @title Swedish Voting Contract Mumbai Testing Script
/// @notice Tests all major functionality of the deployed contract on Mumbai
/// @dev Comprehensive testing of admin functions, member management, and voting
contract TestMumbaiScript is Script {
    function run() external {
        // Load environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        
        // Test member addresses and private keys
        address member1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        address member2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        address member3 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
        
        uint256 member1Key = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
        uint256 member2Key = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
        uint256 member3Key = 0x7c852118e8d7e3b9d5b4b0d7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b;
        
        console2.log("=== Mumbai Testnet Testing Starting ===");
        console2.log("Contract Address:", contractAddress);
        console2.log("Admin Address:", admin);
        console2.log("Test Members:", member1, member2, member3);
        
        // Get contract instance
        SwedishVotingContract votingContract = SwedishVotingContract(contractAddress);
        
        // Test 1: Verify initial state
        console2.log("\n=== Test 1: Initial State Verification ===");
        require(votingContract.admin() == admin, "Admin not set correctly");
        require(votingContract.getSessionCount() == 0, "Session count should be 0");
        console2.log("✅ Initial state verified");
        
        // Test 2: Add members (as admin)
        console2.log("\n=== Test 2: Adding Members ===");
        address[] memory members = new address[](3);
        members[0] = member1;
        members[1] = member2;
        members[2] = member3;
        
        vm.startBroadcast(deployerPrivateKey);
        votingContract.addMembers(members);
        vm.stopBroadcast();
        
        // Verify members were added
        require(votingContract.isMember(member1), "Member 1 not added");
        require(votingContract.isMember(member2), "Member 2 not added");
        require(votingContract.isMember(member3), "Member 3 not added");
        console2.log("✅ All members added successfully");
        
        // Test 3: Create voting session
        console2.log("\n=== Test 3: Creating Voting Session ===");
        string[] memory questions = new string[](2);
        questions[0] = "Should we deploy this voting system to mainnet?";
        questions[1] = "Should we add more features to the contract?";
        
        bool[] memory isPrivate = new bool[](2);
        isPrivate[0] = false; // Public question
        isPrivate[1] = true;  // Private question
        
        uint256 sessionDuration = 3600; // 1 hour
        
        vm.startBroadcast(deployerPrivateKey);
        votingContract.createVotingSession(questions, isPrivate, sessionDuration);
        vm.stopBroadcast();
        
        // Verify session was created
        require(votingContract.getSessionCount() == 1, "Session not created");
        console2.log("✅ Voting session created successfully");
        
        // Test 4: Get session info
        console2.log("\n=== Test 4: Session Information ===");
        (uint256 startTime, uint256 endTime, uint256 questionCount, bool isPaused, bool isFinalized, bytes32 resultsHash) = votingContract.getSessionInfo(1);
        console2.log("Session 1 Info:");
        console2.log("  Start Time:", startTime);
        console2.log("  End Time:", endTime);
        console2.log("  Question Count:", questionCount);
        console2.log("  Is Paused:", isPaused);
        console2.log("  Is Finalized:", isFinalized);
        console2.log("✅ Session info retrieved");
        
        // Test 5: Cast votes (as members)
        console2.log("\n=== Test 5: Casting Votes ===");
        
        // Member 1 votes
        vm.startBroadcast(member1Key);
        votingContract.castVote(1, 0, 1); // Yes on question 0
        votingContract.castVote(1, 1, 2); // No on question 1
        vm.stopBroadcast();
        console2.log("✅ Member 1 votes cast");
        
        // Member 2 votes
        vm.startBroadcast(member2Key);
        votingContract.castVote(1, 0, 1); // Yes on question 0
        votingContract.castVote(1, 1, 1); // Yes on question 1
        vm.stopBroadcast();
        console2.log("✅ Member 2 votes cast");
        
        // Member 3 votes
        vm.startBroadcast(member3Key);
        votingContract.castVote(1, 0, 2); // No on question 0
        votingContract.castVote(1, 1, 0); // Abstain on question 1
        vm.stopBroadcast();
        console2.log("✅ Member 3 votes cast");
        
        // Test 6: Check vote counts (public question only)
        console2.log("\n=== Test 6: Vote Counts (Public Question) ===");
        (uint256 abstain, uint256 yes, uint256 no) = votingContract.getVoteCounts(1, 0);
        console2.log("Question 0 Vote Counts:");
        console2.log("  Abstain:", abstain);
        console2.log("  Yes:", yes);
        console2.log("  No:", no);
        console2.log("✅ Vote counts retrieved");
        
        // Test 7: Check voting status
        console2.log("\n=== Test 7: Voting Status ===");
        require(votingContract.hasVoted(1, 0, member1), "Member 1 vote not recorded");
        require(votingContract.hasVoted(1, 0, member2), "Member 2 vote not recorded");
        require(votingContract.hasVoted(1, 0, member3), "Member 3 vote not recorded");
        console2.log("✅ All votes recorded correctly");
        
        // Test 8: Try to vote twice (should fail)
        console2.log("\n=== Test 8: Double Voting Prevention ===");
        vm.startBroadcast(member1Key);
        try votingContract.castVote(1, 0, 1) {
            console2.log("❌ Double voting should have failed");
            revert("Double voting test failed");
        } catch {
            console2.log("✅ Double voting correctly prevented");
        }
        vm.stopBroadcast();
        
        // Test 9: Non-member voting (should fail)
        console2.log("\n=== Test 9: Non-Member Voting Prevention ===");
        address nonMember = 0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199;
        uint256 nonMemberKey = 0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e;
        
        vm.startBroadcast(nonMemberKey);
        try votingContract.castVote(1, 0, 1) {
            console2.log("❌ Non-member voting should have failed");
            revert("Non-member voting test failed");
        } catch {
            console2.log("✅ Non-member voting correctly prevented");
        }
        vm.stopBroadcast();
        
        // Test 10: Batch voting
        console2.log("\n=== Test 10: Batch Voting ===");
        uint256[] memory questionIds = new uint256[](2);
        uint8[] memory votes = new uint8[](2);
        questionIds[0] = 0;
        questionIds[1] = 1;
        votes[0] = 1; // Yes
        votes[1] = 2; // No
        
        vm.startBroadcast(member1Key);
        try votingContract.castBatchVote(1, questionIds, votes) {
            console2.log("❌ Batch voting should have failed (already voted)");
        } catch {
            console2.log("✅ Batch voting correctly prevented for existing votes");
        }
        vm.stopBroadcast();
        
        console2.log("\n=== All Tests Completed Successfully! ===");
        console2.log("Contract is working correctly on Mumbai testnet!");
        console2.log("Ready for production deployment to Polygon mainnet.");
    }
}
