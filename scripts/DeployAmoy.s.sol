// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {SwedishVotingContract} from "../contracts/SwedishVotingContract.sol";

/// @title Swedish Voting Contract Amoy Deployment Script
/// @notice Deploys the Swedish Association Voting Contract to Polygon Amoy testnet
/// @dev Includes comprehensive parameter validation and deployment verification
contract DeployAmoyScript is Script {
    function run() external {
        // Load environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        
        // Validate environment setup
        require(admin != address(0), "Invalid admin address");
        require(deployerPrivateKey != 0, "Invalid private key");
        
        console2.log("=== Polygon Amoy Testnet Deployment Starting ===");
        console2.log("Admin Address:", admin);
        console2.log("Deployer Address:", vm.addr(deployerPrivateKey));
        console2.log("Network: Polygon Amoy Testnet (Chain ID: 80002)");
        console2.log("RPC URL:", vm.envString("AMOY_RPC_URL"));
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the voting contract
        SwedishVotingContract votingContract = new SwedishVotingContract(admin);
        
        vm.stopBroadcast();
        
        // Comprehensive deployment verification
        console2.log("\n=== Deployment Results ===");
        console2.log("Contract Address:", address(votingContract));
        console2.log("Admin Address:", admin);
        console2.log("Deployer:", vm.addr(deployerPrivateKey));
        console2.log("Block Number:", block.number);
        console2.log("Block Timestamp:", block.timestamp);
        
        // Verify contract state
        require(votingContract.admin() == admin, "Admin not set correctly");
        require(votingContract.getSessionCount() == 0, "Session count should be 0");
        require(votingContract.hasRole(votingContract.ADMIN_ROLE(), admin), "Admin role not granted");
        
        console2.log("\n=== Contract Verification ===");
        console2.log("Admin set correctly:", votingContract.admin());
        console2.log("Session count initialized:", votingContract.getSessionCount());
        console2.log("Admin role granted:", votingContract.hasRole(votingContract.ADMIN_ROLE(), admin));
        console2.log("MAX_SESSION_DURATION:", votingContract.MAX_SESSION_DURATION());
        console2.log("MIN_SESSION_DURATION:", votingContract.MIN_SESSION_DURATION());
        console2.log("MAX_BATCH_SIZE:", votingContract.MAX_BATCH_SIZE());
        
        // Test basic functionality
        console2.log("\n=== Basic Functionality Test ===");
        address testMember = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        require(!votingContract.isMember(testMember), "Test member should not be member initially");
        console2.log("Non-member check passed");
        
        console2.log("\n=== Deployment Verification Successful ===");
        console2.log("Contract is ready for testing on Polygon Amoy testnet!");
        console2.log("View on Amoy Block Explorer: https://amoy.polygonscan.com/address/", address(votingContract));
        
        // Save contract address to environment for later use
        console2.log("\n=== Next Steps ===");
        console2.log("1. Add this contract address to your .env file:");
        console2.log("   CONTRACT_ADDRESS=", address(votingContract));
        console2.log("2. Get test MATIC from: https://faucet.polygon.technology/");
        console2.log("3. Test the contract with: forge script scripts/TestAmoy.s.sol --rpc-url $AMOY_RPC_URL --broadcast");
    }
}
