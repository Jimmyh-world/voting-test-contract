# 🧪 Polygon Testnets Deployment Guide

## Complete Setup for Swedish Voting Contract

> **📖 Navigation**: [Quick Start](QUICK_START.md) | [Design Docs](docs/DESIGN_SUMMARY.md) | [README](README.md)

### **Testnet Options**

You now have **two testnet options** for testing your Swedish Voting Contract:

#### **1. Amoy Testnet (Recommended)**

- **Chain ID**: 80002
- **RPC URL**: https://rpc-amoy.polygon.technology
- **Block Explorer**: https://amoy.polygonscan.com/
- **Status**: Newer testnet, future-focused, recommended for new deployments

#### **2. Mumbai Testnet (Established)**

- **Chain ID**: 80001
- **RPC URL**: https://rpc-mumbai.maticvigil.com/
- **Block Explorer**: https://mumbai.polygonscan.com/
- **Status**: Established testnet, widely used, very stable

---

## 🚀 **Quick Start: Choose Your Testnet**

### **Option A: Deploy to Amoy Testnet (Recommended)**

```bash
# 1. Set up environment
cp env.example .env
# Edit .env with your values

# 2. Deploy to Amoy
forge script scripts/DeployAmoy.s.sol \
  --rpc-url https://rpc-amoy.polygon.technology \
  --broadcast \
  --verify \
  --private-key $PRIVATE_KEY

# 3. Test on Amoy
forge script scripts/TestAmoy.s.sol \
  --rpc-url https://rpc-amoy.polygon.technology \
  --broadcast \
  --private-key $PRIVATE_KEY
```

### **Option B: Deploy to Mumbai Testnet**

```bash
# 1. Set up environment
cp env.example .env
# Edit .env with your values

# 2. Deploy to Mumbai
forge script scripts/DeployMumbai.s.sol \
  --rpc-url https://rpc-mumbai.maticvigil.com/ \
  --broadcast \
  --verify \
  --private-key $PRIVATE_KEY

# 3. Test on Mumbai
forge script scripts/TestMumbai.s.sol \
  --rpc-url https://rpc-mumbai.maticvigil.com/ \
  --broadcast \
  --private-key $PRIVATE_KEY
```

---

## 📋 **Environment Setup**

### **Required Environment Variables**

```bash
# Choose your testnet configuration
MUMBAI_RPC_URL="https://rpc-mumbai.maticvigil.com/"
MUMBAI_CHAIN_ID=80001

AMOY_RPC_URL="https://rpc-amoy.polygon.technology"
AMOY_CHAIN_ID=80002

# API Keys (Get free from https://polygonscan.com/apis)
POLYGONSCAN_API_KEY="your_polygonscan_api_key_here"

# Deployment Configuration
PRIVATE_KEY="your_private_key_here"
ADMIN_ADDRESS="your_admin_address_here"

# Contract Addresses (will be filled after deployment)
CONTRACT_ADDRESS=""
```

---

## 🪙 **Get Test MATIC**

### **Official Polygon Faucet (Supports Both Testnets)**

1. **Official Polygon Faucet**: https://faucet.polygon.technology/
   - Supports both Mumbai and Amoy testnets
   - Requires wallet address and social media verification
   - Provides 0.1-1 MATIC per request

### **Additional Mumbai Faucets**

1. **Alchemy Faucet**: https://mumbaifaucet.com/
2. **QuickNode Faucet**: https://faucet.quicknode.com/polygon/mumbai

---

## 🔧 **Network Configuration**

### **Add Amoy to MetaMask**

```javascript
const addAmoyNetwork = async () => {
  await window.ethereum.request({
    method: 'wallet_addEthereumChain',
    params: [
      {
        chainId: '0x13882', // 80002 in hex
        chainName: 'Polygon Amoy Testnet',
        nativeCurrency: {
          name: 'MATIC',
          symbol: 'MATIC',
          decimals: 18,
        },
        rpcUrls: ['https://rpc-amoy.polygon.technology'],
        blockExplorerUrls: ['https://amoy.polygonscan.com/'],
      },
    ],
  });
};
```

### **Add Mumbai to MetaMask**

```javascript
const addMumbaiNetwork = async () => {
  await window.ethereum.request({
    method: 'wallet_addEthereumChain',
    params: [
      {
        chainId: '0x13881', // 80001 in hex
        chainName: 'Polygon Mumbai Testnet',
        nativeCurrency: {
          name: 'MATIC',
          symbol: 'MATIC',
          decimals: 18,
        },
        rpcUrls: ['https://rpc-mumbai.maticvigil.com/'],
        blockExplorerUrls: ['https://mumbai.polygonscan.com/'],
      },
    ],
  });
};
```

---

## 🧪 **Testing Commands**

### **Amoy Testnet Commands (Recommended)**

```bash
# Check balance
cast balance $ADMIN_ADDRESS --rpc-url https://rpc-amoy.polygon.technology

# Deploy contract
forge script scripts/DeployAmoy.s.sol \
  --rpc-url https://rpc-amoy.polygon.technology \
  --broadcast \
  --verify \
  --private-key $PRIVATE_KEY

# Test contract
forge script scripts/TestAmoy.s.sol \
  --rpc-url https://rpc-amoy.polygon.technology \
  --broadcast \
  --private-key $PRIVATE_KEY

# Manual testing
cast call $CONTRACT_ADDRESS "admin()" --rpc-url https://rpc-amoy.polygon.technology
```

### **Mumbai Testnet Commands**

```bash
# Check balance
cast balance $ADMIN_ADDRESS --rpc-url https://rpc-mumbai.maticvigil.com/

# Deploy contract
forge script scripts/DeployMumbai.s.sol \
  --rpc-url https://rpc-mumbai.maticvigil.com/ \
  --broadcast \
  --verify \
  --private-key $PRIVATE_KEY

# Test contract
forge script scripts/TestMumbai.s.sol \
  --rpc-url https://rpc-mumbai.maticvigil.com/ \
  --broadcast \
  --private-key $PRIVATE_KEY

# Manual testing
cast call $CONTRACT_ADDRESS "admin()" --rpc-url https://rpc-mumbai.maticvigil.com/
```

---

## 📊 **Testnet Comparison**

| Feature               | Amoy (Recommended)          | Mumbai                    |
| --------------------- | --------------------------- | ------------------------- |
| **Chain ID**          | 80002                       | 80001                     |
| **RPC URL**           | rpc-amoy.polygon.technology | rpc-mumbai.maticvigil.com |
| **Block Explorer**    | amoy.polygonscan.com        | mumbai.polygonscan.com    |
| **Status**            | Newer, future-focused       | Established               |
| **Faucet Support**    | Official faucet             | Multiple faucets          |
| **Community Support** | Growing                     | High                      |
| **Stability**         | Stable                      | Very Stable               |
| **Gas Costs**         | Very low                    | Low                       |
| **Performance**       | Faster                      | Good                      |

---

## 🎯 **Recommendation**

### **For New Deployments: Use Amoy**

- Newer features and improvements
- Better performance and lower gas costs
- Future-focused development
- Less congestion
- Official Polygon support

### **For Established Projects: Use Mumbai**

- More established and widely supported
- Multiple faucets available
- Better documentation and community support
- Very stable for learning and testing

### **For Production Testing: Use Both**

- Test on both testnets to ensure compatibility
- Different environments may reveal different issues
- Better preparation for mainnet deployment

---

## 🚀 **Deployment Workflow**

### **Step 1: Choose Your Testnet**

```bash
# For Amoy (recommended)
export TESTNET="amoy"
export RPC_URL="https://rpc-amoy.polygon.technology"
export DEPLOY_SCRIPT="scripts/DeployAmoy.s.sol"
export TEST_SCRIPT="scripts/TestAmoy.s.sol"

# For Mumbai
export TESTNET="mumbai"
export RPC_URL="https://rpc-mumbai.maticvigil.com/"
export DEPLOY_SCRIPT="scripts/DeployMumbai.s.sol"
export TEST_SCRIPT="scripts/TestMumbai.s.sol"
```

### **Step 2: Deploy and Test**

```bash
# Deploy
forge script $DEPLOY_SCRIPT \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify \
  --private-key $PRIVATE_KEY

# Test
forge script $TEST_SCRIPT \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $PRIVATE_KEY
```

---

## 🔍 **Monitoring and Verification**

### **Amoy Block Explorer**

- **URL**: https://amoy.polygonscan.com/
- **Features**: Full transaction history, contract verification, event logs

### **Mumbai Block Explorer**

- **URL**: https://mumbai.polygonscan.com/
- **Features**: Full transaction history, contract verification, event logs

### **Verification Commands**

```bash
# Verify contract deployment
cast call $CONTRACT_ADDRESS "admin()" --rpc-url $RPC_URL

# Check session count
cast call $CONTRACT_ADDRESS "getSessionCount()" --rpc-url $RPC_URL

# Verify constants
cast call $CONTRACT_ADDRESS "MAX_SESSION_DURATION()" --rpc-url $RPC_URL
```

---

## 🚨 **Troubleshooting**

### **Common Issues**

#### **Insufficient Balance**

```bash
# Check balance
cast balance $ADMIN_ADDRESS --rpc-url $RPC_URL

# Get test MATIC from official faucet
# https://faucet.polygon.technology/ (supports both testnets)
```

#### **RPC Connection Issues**

```bash
# Try alternative RPC URLs for Amoy:
# - https://rpc-amoy.polygon.technology (official)
# - https://polygon-amoy.infura.io/v3/YOUR_PROJECT_ID

# Try alternative RPC URLs for Mumbai:
# - https://rpc-mumbai.maticvigil.com/ (official)
# - https://polygon-mumbai.infura.io/v3/YOUR_PROJECT_ID
# - https://polygon-mumbai.g.alchemy.com/v2/YOUR_API_KEY
```

#### **Contract Verification Failed**

```bash
# Manual verification
# Amoy: https://amoy.polygonscan.com/verifyContract
# Mumbai: https://mumbai.polygonscan.com/verifyContract
```

#### **Private Key Issues**

```bash
# Ensure private key starts with 0x
# Example: 0x1234567890abcdef...

# Check private key format
cast wallet address --private-key $PRIVATE_KEY
```

---

## 🎉 **Next Steps**

### **After Successful Testnet Deployment:**

1. **Test All Functionality**

   - Member management
   - Voting sessions
   - Vote casting
   - Security features

2. **Deploy to Polygon Mainnet**

   ```bash
   forge script scripts/Deploy.s.sol \
     --rpc-url https://polygon-rpc.com \
     --broadcast \
     --verify \
     --private-key $PRIVATE_KEY
   ```

3. **Build Production Frontend**
4. **Launch with Your Swedish Association!**

---

## 💡 **Pro Tips**

### **Testing Strategy**

- **Start with Amoy** for initial testing (recommended)
- **Test on Mumbai** for broader compatibility
- **Use both** for comprehensive validation

### **Gas Optimization**

- Both testnets use low gas prices
- Perfect for testing without high costs
- Use batch operations for efficiency

### **Development Workflow**

- Deploy to testnet first
- Test thoroughly
- Deploy to mainnet only after validation
- Monitor and maintain

### **Security Best Practices**

- Never use real private keys on testnets
- Use dedicated test wallets
- Verify all transactions on block explorer
- Test all security features thoroughly

---

## 📚 **Additional Resources**

- **🚀 Quick Start**: [`QUICK_START.md`](QUICK_START.md) - 5-minute setup guide
- **🏗️ Design Documentation**: [`docs/DESIGN_SUMMARY.md`](docs/DESIGN_SUMMARY.md) - Technical specifications
- **📖 Main README**: [`README.md`](README.md) - Project overview
- **🔧 Foundry Documentation**: https://book.getfoundry.sh/
- **🌐 Polygon Documentation**: https://docs.polygon.technology/

---

**Ready to deploy?** Choose your testnet and start testing! 🚀

- **Amoy (Recommended)**: `forge script scripts/DeployAmoy.s.sol --rpc-url https://rpc-amoy.polygon.technology --broadcast`
- **Mumbai**: `forge script scripts/DeployMumbai.s.sol --rpc-url https://rpc-mumbai.maticvigil.com/ --broadcast`
