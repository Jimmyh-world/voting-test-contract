# Swedish Association Voting Contract

A secure, transparent smart contract for Swedish association (förening) governance processes including Annual General Meetings and Special Meetings.

## 🚀 **Quick Start**

### **Deploy to Polygon Testnet (Recommended)**

```bash
# 1. Set up environment
cp env.example .env
# Edit .env with your values

# 2. Deploy to Amoy testnet (newer, recommended)
forge script scripts/deploy/DeployAmoy.s.sol \
  --rpc-url https://rpc-amoy.polygon.technology \
  --broadcast \
  --verify \
  --private-key $PRIVATE_KEY

# 3. Test functionality
forge script scripts/test/TestAmoy.s.sol \
  --rpc-url https://rpc-amoy.polygon.technology \
  --broadcast \
  --private-key $PRIVATE_KEY
```

**📖 Full Guides:**

- **Quick Start**: [`docs/user-guides/QUICK_START.md`](docs/user-guides/QUICK_START.md) - 5-minute setup
- **Comprehensive Guide**: [`docs/user-guides/POLYGON_TESTNETS_GUIDE.md`](docs/user-guides/POLYGON_TESTNETS_GUIDE.md) - Complete deployment guide
- **Design Documentation**: [`docs/technical/DESIGN_SUMMARY.md`](docs/technical/DESIGN_SUMMARY.md) - Technical specifications
- **Navigation Guide**: [`NAVIGATION.md`](NAVIGATION.md) - Repository structure & quick links

## Overview

This contract enables Swedish associations to conduct secure, transparent voting on governance matters with the following key features:

- **Secure Voting**: One vote per member per question, non-transferable
- **Session Management**: Create voting sessions with multiple questions
- **Privacy Controls**: Configurable privacy settings per question
- **Batch Operations**: Gas-efficient batch voting and member registration
- **Emergency Controls**: Pause functionality for crisis situations
- **Immutable Results**: Hash-based result verification

## Key Design Principles

- **KISS Compliance**: Simple, focused functionality
- **Security First**: Comprehensive access controls and validation
- **Gas Optimization**: Organization pays all gas costs
- **Transparency**: All operations emit events for off-chain verification

## Contract Architecture

### Core Functions

#### Admin Functions (Organization)

- `createVotingSession()` - Create new voting sessions with multiple questions
- `pauseSession()` - Pause voting sessions under extenuating circumstances
- `finalizeSession()` - Record final results and close voting sessions
- `addMembers()` - Add verified members to the on-chain registry

#### Member Functions

- `castVote()` - Cast vote on a specific question (yes/no/abstain)
- `batchVote()` - Vote on multiple questions in a single transaction

#### View Functions

- `getSessionInfo()` - Get voting session details
- `getVoteCounts()` - Get current vote counts for questions
- `isMember()` - Check if address is a registered member
- `getSessionCount()` - Get total number of voting sessions
- `hasVoted()` - Check if member has voted on specific question

### Data Structures

```solidity
struct Session {
    uint256 startTime;
    uint256 endTime;
    uint256 questionCount;
    bool isPaused;
    bool isFinalized;
    bytes32 resultsHash;
    mapping(uint256 => Question) questions;
    mapping(uint256 => mapping(address => bool)) hasVoted;
    mapping(uint256 => mapping(uint8 => uint256)) voteCounts;
    bool exists;
}

struct Question {
    string text;
    bool isPrivate;
    bool exists;
}

struct VoteCounts {
    uint256 abstainCount;
    uint256 yesCount;
    uint256 noCount;
}
```

## Security Features

### Access Control

- **Immutable Admin**: Single admin address set at deployment
- **Role-Based**: OpenZeppelin AccessControl for admin functions
- **Member Verification**: Off-chain verification with on-chain registration

### Input Validation

- **Session Duration**: 30 minutes to 2 hours
- **Vote Values**: 0 (abstain), 1 (yes), 2 (no)
- **Question Count**: Must match privacy settings array
- **Member Addresses**: No zero addresses allowed

### Threat Mitigations

- **Reentrancy Protection**: CEI pattern implementation
- **Vote Integrity**: One vote per member per question
- **Session Security**: Immutable parameters once created
- **Emergency Controls**: Pause functionality for crisis situations

## Installation & Setup

### Prerequisites

- Foundry (latest version)
- Node.js (for additional tooling)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd voting

# Install dependencies
forge install

# Build the project
forge build
```

### Environment Setup

Create a `.env` file with the following variables:

```env
# Polygon Testnet Configuration
AMOY_RPC_URL="https://rpc-amoy.polygon.technology"
MUMBAI_RPC_URL="https://rpc-mumbai.maticvigil.com/"

# API Keys (Get free from https://polygonscan.com/apis)
POLYGONSCAN_API_KEY="your_polygonscan_api_key_here"

# Deployment Configuration
PRIVATE_KEY="your_private_key_here"
ADMIN_ADDRESS="your_admin_address_here"
```

## Testing

### Run All Tests

```bash
forge test
```

### Run Specific Test Categories

```bash
# Unit tests
forge test --match-test test_CastVote

# Security tests
forge test --match-test test_Security

# Gas optimization tests
forge test --match-test test_Gas
```

### Test Coverage

```bash
forge coverage
```

## Deployment

### Local Development

```bash
# Start local node
anvil

# Deploy to local network
forge script scripts/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

### Polygon Testnet Deployment

```bash
# Deploy to Amoy testnet (recommended)
forge script scripts/DeployAmoy.s.sol \
  --rpc-url https://rpc-amoy.polygon.technology \
  --broadcast \
  --verify \
  --private-key $PRIVATE_KEY

# Deploy to Mumbai testnet
forge script scripts/DeployMumbai.s.sol \
  --rpc-url https://rpc-mumbai.maticvigil.com/ \
  --broadcast \
  --verify \
  --private-key $PRIVATE_KEY
```

### Polygon Mainnet Deployment

```bash
# Deploy to Polygon mainnet
forge script scripts/Deploy.s.sol \
  --rpc-url https://polygon-rpc.com \
  --broadcast \
  --verify \
  --private-key $PRIVATE_KEY
```

## Usage Examples

### Creating a Voting Session

```solidity
// Admin creates a voting session
string[] memory questions = new string[](3);
questions[0] = "Should we increase membership fees?";
questions[1] = "Should we organize a summer event?";
questions[2] = "Should we update the bylaws?";

bool[] memory isPrivate = new bool[](3);
isPrivate[0] = false; // Public
isPrivate[1] = true;  // Private
isPrivate[2] = false; // Public

uint256 sessionId = votingContract.createVotingSession(questions, isPrivate, 1 hours);
```

### Adding Members

```solidity
// Admin adds verified members
address[] memory members = new address[](3);
members[0] = member1;
members[1] = member2;
members[2] = member3;

votingContract.addMembers(members);
```

### Casting Votes

```solidity
// Individual vote
votingContract.castVote(sessionId, 0, 1); // Yes vote on question 0

// Batch vote
uint256[] memory questionIds = new uint256[](2);
questionIds[0] = 0;
questionIds[1] = 2;

uint8[] memory votes = new uint8[](2);
votes[0] = 1; // Yes
votes[1] = 2; // No

votingContract.batchVote(sessionId, questionIds, votes);
```

### Finalizing Results

```solidity
// Admin finalizes session with results hash
bytes32 resultsHash = keccak256(abi.encodePacked("final_results_data"));
votingContract.finalizeSession(sessionId, resultsHash);
```

## Gas Optimization

### Batch Operations

- **Batch Voting**: Vote on multiple questions in one transaction
- **Batch Member Addition**: Add multiple members efficiently
- **Gas Sponsorship**: Organization pays all gas costs

### Storage Efficiency

- **Packed Structs**: Efficient data storage
- **Minimal On-chain Data**: Only essential data stored
- **Event-based History**: Use events for historical data

## Security Considerations

### For Organizations

- **Admin Key Management**: Secure admin private key storage
- **Member Verification**: Robust off-chain verification process
- **Emergency Procedures**: Plan for pause functionality usage

### For Members

- **Wallet Security**: Secure member wallet management
- **Vote Verification**: Verify votes through events
- **Result Verification**: Verify final result hashes

## Development

### Project Structure

```
├── contracts/                    # Smart contracts
│   ├── SwedishVotingContract.sol
│   └── interfaces/
│       └── ISwedishVoting.sol
├── scripts/                      # Deployment & testing scripts
│   ├── deploy/                   # Deployment scripts
│   │   ├── DeployAmoy.s.sol
│   │   ├── DeployMumbai.s.sol
│   │   └── Deploy.s.sol
│   ├── test/                     # Testing scripts
│   │   ├── TestAmoy.s.sol
│   │   ├── SimpleTestAmoy.s.sol
│   │   └── TestMumbai.s.sol
│   └── utils/                    # Utility scripts
│       └── setup-mumbai.sh
├── docs/                         # Documentation
│   ├── user-guides/              # User-focused guides
│   │   ├── QUICK_START.md
│   │   └── POLYGON_TESTNETS_GUIDE.md
│   ├── technical/                # Technical documentation
│   │   ├── DESIGN_SUMMARY.md
│   │   ├── SECURITY_FIXES_SUMMARY.md
│   │   └── IMPLEMENTATION_SUMMARY.md
│   └── reference/                # Reference materials
│       ├── design/
│       └── architecture/
├── test/                         # Foundry test files
│   └── SwedishVotingContract.t.sol
├── NAVIGATION.md                 # Repository navigation guide
└── README.md                     # Project overview
```

**📖 See [NAVIGATION.md](NAVIGATION.md) for detailed directory structure and quick links.**

### Contributing

1. Follow the existing code style and patterns
2. Add comprehensive tests for new features
3. Update documentation for any changes
4. Ensure all tests pass before submitting

### Code Quality

- **Static Analysis**: Run Slither for security analysis
- **Gas Optimization**: Monitor gas usage in tests
- **Documentation**: Maintain comprehensive NatSpec comments

## License

MIT License - see LICENSE file for details.

## Support

For questions or support, please refer to the documentation in the `docs/` directory or create an issue in the repository.

## Audit Status

This contract has been designed with security best practices and includes comprehensive testing. For production use, consider:

1. **External Audit**: Professional security audit
2. **Formal Verification**: Mathematical proof of correctness
3. **Bug Bounty**: Community security testing
4. **Gradual Deployment**: Start with small-scale testing

---

**Disclaimer**: This software is provided "as is" without warranty. Use at your own risk and ensure proper testing before production deployment.
