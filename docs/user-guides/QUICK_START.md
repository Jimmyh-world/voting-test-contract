# 🚀 Quick Start: Deploy to Polygon Testnet

## **5-Minute Setup Guide**

### **Step 1: Get Test MATIC (Free)**

```bash
# Visit the official Polygon faucet to get free test MATIC:
# https://faucet.polygon.technology/
#
# Supports both Mumbai and Amoy testnets
# You'll need your wallet address and may need to verify via social media
```

### **Step 2: Set Up Environment**

```bash
# Copy environment template
cp env.example .env

# Edit .env with your values
nano .env
```

**Required values in .env:**

```bash
# Choose your testnet (recommended: Amoy)
AMOY_RPC_URL="https://rpc-amoy.polygon.technology"
MUMBAI_RPC_URL="https://rpc-mumbai.maticvigil.com/"

# Your deployment credentials
PRIVATE_KEY="your_private_key_here"
ADMIN_ADDRESS="your_admin_address_here"

# Optional: For contract verification
POLYGONSCAN_API_KEY="your_api_key_here"  # Get free from polygonscan.com/apis
```

### **Step 3: Deploy Contract**

```bash
# Option A: Deploy to Amoy testnet (recommended - newer, faster)
forge script scripts/DeployAmoy.s.sol \
  --rpc-url https://rpc-amoy.polygon.technology \
  --broadcast \
  --verify \
  --private-key $PRIVATE_KEY

# Option B: Deploy to Mumbai testnet (established)
forge script scripts/DeployMumbai.s.sol \
  --rpc-url https://rpc-mumbai.maticvigil.com/ \
  --broadcast \
  --verify \
  --private-key $PRIVATE_KEY
```

### **Step 4: Test Contract**

```bash
# Test on Amoy testnet
forge script scripts/TestAmoy.s.sol \
  --rpc-url https://rpc-amoy.polygon.technology \
  --broadcast \
  --private-key $PRIVATE_KEY

# Test on Mumbai testnet
forge script scripts/TestMumbai.s.sol \
  --rpc-url https://rpc-mumbai.maticvigil.com/ \
  --broadcast \
  --private-key $PRIVATE_KEY
```

### **Step 5: View on Block Explorer**

```bash
# Amoy Block Explorer: https://amoy.polygonscan.com/address/YOUR_CONTRACT_ADDRESS
# Mumbai Block Explorer: https://mumbai.polygonscan.com/address/YOUR_CONTRACT_ADDRESS
# Replace YOUR_CONTRACT_ADDRESS with the address from deployment output
```

---

## **Quick Commands Reference**

### **Check Balance**

```bash
# Amoy testnet
cast balance $ADMIN_ADDRESS --rpc-url https://rpc-amoy.polygon.technology

# Mumbai testnet
cast balance $ADMIN_ADDRESS --rpc-url https://rpc-mumbai.maticvigil.com/
```

### **Add Members**

```bash
# Add test members to your contract
cast send $CONTRACT_ADDRESS \
  "addMembers(address[])" \
  "[0x70997970C51812dc3A010C7d01b50e0d17dc79C8]" \
  --rpc-url https://rpc-amoy.polygon.technology \
  --private-key $PRIVATE_KEY
```

### **Create Voting Session**

```bash
# Create a test voting session
cast send $CONTRACT_ADDRESS \
  "createVotingSession(string[],bool[],uint256)" \
  "[\"Should we deploy to mainnet?\"]" \
  "[false]" \
  3600 \
  --rpc-url https://rpc-amoy.polygon.technology \
  --private-key $PRIVATE_KEY
```

### **Cast Vote**

```bash
# Cast a vote (as a member)
cast send $CONTRACT_ADDRESS \
  "castVote(uint256,uint256,uint8)" \
  1 0 1 \
  --rpc-url https://rpc-amoy.polygon.technology \
  --private-key $MEMBER_PRIVATE_KEY
```

### **Check Vote Counts**

```bash
# Get vote counts for a question
cast call $CONTRACT_ADDRESS \
  "getVoteCounts(uint256,uint256)" \
  1 0 \
  --rpc-url https://rpc-amoy.polygon.technology
```

---

## **Testnet Comparison**

| Feature            | Amoy Testnet                | Mumbai Testnet            |
| ------------------ | --------------------------- | ------------------------- |
| **Chain ID**       | 80002                       | 80001                     |
| **Status**         | Newer, recommended          | Established               |
| **RPC URL**        | rpc-amoy.polygon.technology | rpc-mumbai.maticvigil.com |
| **Block Explorer** | amoy.polygonscan.com        | mumbai.polygonscan.com    |
| **Gas Costs**      | Very low                    | Low                       |
| **Stability**      | Stable                      | Very stable               |

**Recommendation**: Start with **Amoy testnet** for newer features and better performance.

---

## **Troubleshooting**

### **No MATIC Balance**

- Get test MATIC from: https://faucet.polygon.technology/
- Wait a few minutes for transaction to confirm
- Check your wallet address is correct

### **Deployment Fails**

- Check your private key is correct (should start with 0x)
- Ensure you have enough MATIC for gas (0.1 MATIC is plenty)
- Verify RPC URL is accessible
- Check network connection

### **Contract Not Verified**

- Manual verification:
  - Amoy: https://amoy.polygonscan.com/verifyContract
  - Mumbai: https://mumbai.polygonscan.com/verifyContract
- Select compiler version: 0.8.24
- Upload source code

### **RPC Connection Issues**

```bash
# Try alternative RPC URLs for Amoy:
# - https://rpc-amoy.polygon.technology (official)
# - https://polygon-amoy.infura.io/v3/YOUR_PROJECT_ID

# Try alternative RPC URLs for Mumbai:
# - https://rpc-mumbai.maticvigil.com/ (official)
# - https://polygon-mumbai.infura.io/v3/YOUR_PROJECT_ID
# - https://polygon-mumbai.g.alchemy.com/v2/YOUR_API_KEY
```

---

## **Next Steps**

1. **Test all functionality** using the test scripts
2. **Deploy to Polygon mainnet** when ready for production
3. **Build frontend** to interact with your contract
4. **Launch with your Swedish association!**

---

## **Additional Resources**

- **📖 Comprehensive Guide**: [`POLYGON_TESTNETS_GUIDE.md`](POLYGON_TESTNETS_GUIDE.md) - Complete deployment guide
- **🏗️ Design Documentation**: [`docs/DESIGN_SUMMARY.md`](docs/DESIGN_SUMMARY.md) - Technical specifications
- **🔧 Foundry Documentation**: https://book.getfoundry.sh/
- **🌐 Polygon Documentation**: https://docs.polygon.technology/

---

**Need help?** Check the comprehensive guide or create an issue in the repository!
