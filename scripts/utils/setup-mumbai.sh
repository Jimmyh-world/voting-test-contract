#!/bin/bash

# Mumbai Testnet Setup Script for Swedish Voting Contract
# This script helps you set up your environment for Mumbai deployment

set -e

echo "🧪 Setting up Mumbai Testnet Deployment for Swedish Voting Contract"
echo "=================================================================="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    echo "✅ .env file created"
    echo "⚠️  Please edit .env file with your actual values:"
    echo "   - PRIVATE_KEY: Your wallet private key"
    echo "   - ADMIN_ADDRESS: Your admin wallet address"
    echo "   - POLYGONSCAN_API_KEY: Get from https://polygonscan.com/apis"
    echo ""
    echo "After editing .env, run this script again to continue."
    exit 0
fi

# Load environment variables
source .env

# Check if required variables are set
if [ -z "$PRIVATE_KEY" ] || [ "$PRIVATE_KEY" = "your_private_key_here" ]; then
    echo "❌ PRIVATE_KEY not set in .env file"
    echo "Please edit .env and set your private key"
    exit 1
fi

if [ -z "$ADMIN_ADDRESS" ] || [ "$ADMIN_ADDRESS" = "your_admin_address_here" ]; then
    echo "❌ ADMIN_ADDRESS not set in .env file"
    echo "Please edit .env and set your admin address"
    exit 1
fi

if [ -z "$POLYGONSCAN_API_KEY" ] || [ "$POLYGONSCAN_API_KEY" = "your_polygonscan_api_key_here" ]; then
    echo "❌ POLYGONSCAN_API_KEY not set in .env file"
    echo "Please get a free API key from https://polygonscan.com/apis"
    exit 1
fi

echo "✅ Environment variables configured"

# Check if Foundry is installed
if ! command -v forge &> /dev/null; then
    echo "❌ Foundry not found. Please install Foundry first:"
    echo "   curl -L https://foundry.paradigm.xyz | bash"
    echo "   foundryup"
    exit 1
fi

echo "✅ Foundry is installed"

# Check balance
echo "💰 Checking balance on Mumbai testnet..."
BALANCE=$(cast balance $ADMIN_ADDRESS --rpc-url $MUMBAI_RPC_URL 2>/dev/null || echo "0")

if [ "$BALANCE" = "0" ]; then
    echo "⚠️  No MATIC found on Mumbai testnet"
    echo "Please get test MATIC from one of these faucets:"
    echo "   - https://faucet.polygon.technology/"
    echo "   - https://mumbaifaucet.com/"
    echo "   - https://faucet.quicknode.com/polygon/mumbai"
    echo ""
    echo "After getting test MATIC, run this script again."
    exit 1
fi

echo "✅ Balance: $BALANCE wei (≈ $(echo "scale=4; $BALANCE / 1000000000000000000" | bc) MATIC)"

# Build contracts
echo "🔨 Building contracts..."
forge build --profile mumbai

echo "✅ Contracts built successfully"

# Check if contract is already deployed
if [ ! -z "$CONTRACT_ADDRESS" ] && [ "$CONTRACT_ADDRESS" != "" ]; then
    echo "📋 Contract already deployed at: $CONTRACT_ADDRESS"
    echo "Would you like to:"
    echo "1) Test existing contract"
    echo "2) Deploy new contract"
    echo "3) Exit"
    read -p "Choose option (1-3): " choice
    
    case $choice in
        1)
            echo "🧪 Testing existing contract..."
            forge script scripts/TestMumbai.s.sol \
                --rpc-url $MUMBAI_RPC_URL \
                --broadcast \
                --profile mumbai \
                --private-key $PRIVATE_KEY
            ;;
        2)
            echo "🚀 Deploying new contract..."
            forge script scripts/DeployMumbai.s.sol \
                --rpc-url $MUMBAI_RPC_URL \
                --broadcast \
                --verify \
                --profile mumbai \
                --private-key $PRIVATE_KEY
            ;;
        3)
            echo "👋 Exiting..."
            exit 0
            ;;
        *)
            echo "❌ Invalid option"
            exit 1
            ;;
    esac
else
    echo "🚀 Deploying contract to Mumbai testnet..."
    forge script scripts/DeployMumbai.s.sol \
        --rpc-url $MUMBAI_RPC_URL \
        --broadcast \
        --verify \
        --profile mumbai \
        --private-key $PRIVATE_KEY
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. View your contract on Mumbai PolygonScan"
echo "2. Run tests: forge script scripts/TestMumbai.s.sol --rpc-url \$MUMBAI_RPC_URL --broadcast"
echo "3. Test manually with cast commands (see MUMBAI_DEPLOYMENT_GUIDE.md)"
echo "4. Deploy to mainnet when ready"
echo ""
echo "Happy testing! 🧪"
