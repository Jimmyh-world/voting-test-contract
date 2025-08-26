# 🧭 Repository Navigation Guide

## 📁 Directory Structure

```
voting-test-contract/
├── 📄 README.md                    # Project overview & quick start
├── 📄 NAVIGATION.md                # This file - navigation guide
├── 📄 foundry.toml                 # Foundry configuration
├── 📄 .env.example                 # Environment template
├── 📄 .gitignore                   # Git ignore rules
│
├── 📁 contracts/                   # Smart contracts
│   ├── 📄 SwedishVotingContract.sol    # Main voting contract
│   └── 📁 interfaces/
│       └── 📄 ISwedishVoting.sol       # Contract interface
│
├── 📁 scripts/                     # Deployment & testing scripts
│   ├── 📁 deploy/                  # Deployment scripts
│   │   ├── 📄 DeployAmoy.s.sol         # Deploy to Amoy testnet
│   │   ├── 📄 DeployMumbai.s.sol       # Deploy to Mumbai testnet
│   │   └── 📄 Deploy.s.sol             # Deploy to mainnet
│   ├── 📁 test/                    # Testing scripts
│   │   ├── 📄 TestAmoy.s.sol           # Comprehensive Amoy tests
│   │   ├── 📄 SimpleTestAmoy.s.sol     # Basic Amoy tests
│   │   ├── 📄 AdvancedTestAmoy.s.sol   # Advanced Amoy tests
│   │   ├── 📄 ComprehensiveTestAmoy.s.sol # Full test suite
│   │   └── 📄 TestMumbai.s.sol         # Mumbai testnet tests
│   └── 📁 utils/                   # Utility scripts
│       └── 📄 setup-mumbai.sh          # Mumbai setup script
│
├── 📁 docs/                        # Documentation
│   ├── 📄 README.md                # Documentation index
│   ├── 📁 user-guides/             # User-focused guides
│   │   ├── 📄 QUICK_START.md           # 5-minute setup guide
│   │   └── 📄 POLYGON_TESTNETS_GUIDE.md # Complete deployment guide
│   ├── 📁 technical/               # Technical documentation
│   │   ├── 📄 DESIGN_SUMMARY.md        # High-level design overview
│   │   ├── 📄 SECURITY_FIXES_SUMMARY.md # Security analysis
│   │   ├── 📄 IMPLEMENTATION_SUMMARY.md # Implementation details
│   │   └── 📄 DOCUMENTATION_SUMMARY.md  # Documentation overview
│   └── 📁 reference/               # Reference materials
│       ├── 📁 design/              # Design documents
│       └── 📁 architecture/        # Architecture documents
│
├── 📁 test/                        # Foundry test files
│   ├── 📄 SwedishVotingContract.t.sol  # Main test suite
│   └── 📄 Counter.t.sol                # Example test
│
├── 📁 lib/                         # Dependencies (git submodules)
│   ├── 📁 forge-std/               # Foundry testing framework
│   └── 📁 openzeppelin-contracts/  # OpenZeppelin contracts
│
└── 📁 .github/                     # GitHub configuration
    └── 📁 workflows/
        └── 📄 test.yml             # CI/CD pipeline
```

## 🚀 Quick Links

### **For New Users**

- **[Quick Start Guide](docs/user-guides/QUICK_START.md)** - Get up and running in 5 minutes
- **[Main README](README.md)** - Project overview and introduction

### **For Deployers**

- **[Polygon Testnets Guide](docs/user-guides/POLYGON_TESTNETS_GUIDE.md)** - Complete deployment instructions
- **[Deployment Scripts](scripts/deploy/)** - Ready-to-use deployment scripts

### **For Developers**

- **[Design Summary](docs/technical/DESIGN_SUMMARY.md)** - High-level architecture
- **[Implementation Summary](docs/technical/IMPLEMENTATION_SUMMARY.md)** - Technical details
- **[Test Scripts](scripts/test/)** - Comprehensive testing suite

### **For Security Reviewers**

- **[Security Analysis](docs/technical/SECURITY_FIXES_SUMMARY.md)** - Security considerations
- **[Contract Interface](contracts/interfaces/ISwedishVoting.sol)** - API reference

## 🛣️ User Journey Paths

### **👤 New User Journey**

1. **Start Here**: [README.md](README.md) - Project overview
2. **Quick Setup**: [QUICK_START.md](docs/user-guides/QUICK_START.md) - 5-minute deployment
3. **Test Functionality**: [scripts/test/SimpleTestAmoy.s.sol](scripts/test/SimpleTestAmoy.s.sol)
4. **Learn More**: [DESIGN_SUMMARY.md](docs/technical/DESIGN_SUMMARY.md)

### **🔧 Developer Journey**

1. **Architecture**: [DESIGN_SUMMARY.md](docs/technical/DESIGN_SUMMARY.md)
2. **Implementation**: [IMPLEMENTATION_SUMMARY.md](docs/technical/IMPLEMENTATION_SUMMARY.md)
3. **Testing**: [scripts/test/](scripts/test/) - Run comprehensive tests
4. **Deployment**: [scripts/deploy/](scripts/deploy/) - Deploy to testnets

### **🔒 Security Reviewer Journey**

1. **Security Analysis**: [SECURITY_FIXES_SUMMARY.md](docs/technical/SECURITY_FIXES_SUMMARY.md)
2. **Contract Code**: [SwedishVotingContract.sol](contracts/SwedishVotingContract.sol)
3. **Test Coverage**: [SwedishVotingContract.t.sol](test/SwedishVotingContract.t.sol)
4. **Interface**: [ISwedishVoting.sol](contracts/interfaces/ISwedishVoting.sol)

### **🚀 Production Deployment Journey**

1. **Testnet Testing**: [POLYGON_TESTNETS_GUIDE.md](docs/user-guides/POLYGON_TESTNETS_GUIDE.md)
2. **Security Review**: [SECURITY_FIXES_SUMMARY.md](docs/technical/SECURITY_FIXES_SUMMARY.md)
3. **Mainnet Deployment**: [scripts/deploy/Deploy.s.sol](scripts/deploy/Deploy.s.sol)
4. **Verification**: [POLYGON_TESTNETS_GUIDE.md](docs/user-guides/POLYGON_TESTNETS_GUIDE.md#contract-verification)

## 🔧 Common Tasks

### **Deploy to Testnet**

```bash
# Amoy (recommended)
forge script scripts/deploy/DeployAmoy.s.sol --rpc-url $AMOY_RPC_URL --broadcast

# Mumbai
forge script scripts/deploy/DeployMumbai.s.sol --rpc-url $MUMBAI_RPC_URL --broadcast
```

### **Run Tests**

```bash
# Local tests
forge test

# Testnet tests
forge script scripts/test/TestAmoy.s.sol --rpc-url $AMOY_RPC_URL --broadcast
```

### **Verify Contract**

```bash
# Amoy
forge verify-contract <CONTRACT_ADDRESS> contracts/SwedishVotingContract.sol:SwedishVotingContract --chain-id 80002 --etherscan-api-key $POLYGONSCAN_API_KEY --constructor-args $(cast abi-encode "constructor(address)" <ADMIN_ADDRESS>)
```

## 🆘 Troubleshooting Quick Reference

### **Deployment Issues**

- **Insufficient funds**: Get test MATIC from [Polygon Faucet](https://faucet.polygon.technology/)
- **RPC errors**: Check your RPC URL in `.env` file
- **Verification fails**: Ensure constructor arguments match deployment

### **Testing Issues**

- **Import errors**: Check script paths after reorganization
- **Gas errors**: Increase gas limit or optimize contract
- **Network issues**: Verify RPC URL and network connectivity

### **Documentation Issues**

- **Broken links**: Check file paths after reorganization
- **Missing files**: Ensure all files are committed and pushed

## 📞 Getting Help

1. **Check this guide** - Most issues are covered here
2. **Review documentation** - [docs/](docs/) contains detailed guides
3. **Run tests** - [scripts/test/](scripts/test/) for verification
4. **Check GitHub Issues** - For known problems and solutions

---

**💡 Tip**: Use `Ctrl+F` to search this file for specific topics or file names!
