// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console2} from "../../lib/forge-std/src/Script.sol";
import {SwedishVotingContract} from "../../contracts/SwedishVotingContract.sol";

/// @title Simple Amoy Test Script
/// @notice Tests core functionality of the deployed contract on Amoy
contract SimpleTestAmoyScript is Script {
    function run() external {
        // Load environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        
        console2.log("=== Simple Amoy Testnet Testing ===");
        console2.log("Contract Address:", contractAddress);
        console2.log("Admin Address:", admin);
        
        // Get contract instance
        SwedishVotingContract votingContract = SwedishVotingContract(contractAddress);
        
        // Test 1: Verify initial state
        console2.log("\n=== Test 1: Initial State ===");
        require(votingContract.admin() == admin, "Admin not set correctly");
        require(votingContract.getSessionCount() == 0, "Session count should be 0");
        console2.log("Initial state verified");
        
        // Test 2: Add members
        console2.log("\n=== Test 2: Adding Members ===");
        address[] memory members = new address[](2);
        members[0] = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        members[1] = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        
        vm.startBroadcast(deployerPrivateKey);
        votingContract.addMembers(members);
        vm.stopBroadcast();
        
        require(votingContract.isMember(members[0]), "Member 1 not added");
        require(votingContract.isMember(members[1]), "Member 2 not added");
        console2.log("Members added successfully");
        
        // Test 3: Create voting session
        console2.log("\n=== Test 3: Creating Session ===");
        string[] memory questions = new string[](1);
        questions[0] = "Should we deploy to mainnet?";
        
        bool[] memory isPrivate = new bool[](1);
        isPrivate[0] = false;
        
        vm.startBroadcast(deployerPrivateKey);
        votingContract.createVotingSession(questions, isPrivate, 3600);
        vm.stopBroadcast();
        
        require(votingContract.getSessionCount() == 1, "Session not created");
        console2.log("Voting session created successfully");
        
        console2.log("\n=== All Core Tests Passed! ===");
        console2.log("Contract is working correctly on Amoy testnet!");
    }
}
