// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console2} from "../../lib/forge-std/src/Script.sol";
import {SwedishVotingContract} from "../../contracts/SwedishVotingContract.sol";

/// @title Swedish Voting Contract Deployment Script
/// @notice Deploys the Swedish Association Voting Contract
/// @dev Includes parameter validation and deployment verification
contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        
        // Validate admin address
        require(admin != address(0), "Invalid admin address");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the voting contract
        SwedishVotingContract votingContract = new SwedishVotingContract(admin);
        
        vm.stopBroadcast();
        
        // Log deployment information
        console2.log("=== Swedish Voting Contract Deployed ===");
        console2.log("Contract Address:", address(votingContract));
        console2.log("Admin Address:", admin);
        console2.log("Deployer:", vm.addr(deployerPrivateKey));
        console2.log("Block Number:", block.number);
        console2.log("Gas Used:", votingContract.admin()); // Trigger a call to verify deployment
        
        // Verify deployment
        require(votingContract.admin() == admin, "Admin not set correctly");
        require(votingContract.getSessionCount() == 0, "Session count should be 0");
        
        console2.log("=== Deployment Verification Successful ===");
    }
}
