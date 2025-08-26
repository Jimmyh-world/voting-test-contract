# Contract Interfaces: Swedish Association Voting Contract

## Core User Functions

### Organization Functions (Admin)

1. **createVotingSession**: Create a new voting session with multiple questions
2. **pauseSession**: Pause a voting session under extenuating circumstances
3. **finalizeSession**: Record final results and close voting session
4. **addMembers**: Add verified members to the on-chain registry

### Member Functions (Public)

5. **castVote**: Cast vote on a specific question (yes/no/abstain)
6. **batchVote**: Vote on multiple questions in a single transaction (gas optimization)

## View Functions

- **getSessionInfo**: Get voting session details (duration, questions, status)
- **getVoteCounts**: Get current vote counts for questions (if public)
- **getMemberVotes**: Get individual member's votes (if authorized)
- **getSessionResults**: Get final results hash for verification
- **isMember**: Check if address is a registered member
- **getActiveSessions**: List all active voting sessions

## Gas Considerations

**Organization-Paid Functions**:

- createVotingSession
- pauseSession
- finalizeSession
- addMembers

**Member Functions** (gas paid by organization through meta-transactions or sponsorship):

- castVote
- batchVote

**View Functions**:

- All view functions (no gas cost for users)

**Batch Operations**:

- batchVote for multiple questions
- addMembers for multiple members

## Error Handling

**Mistake Prevention**:

- Cannot vote twice on same question
- Cannot vote on closed sessions
- Cannot vote if not a member
- Cannot modify votes once cast

**Reversibility**:

- Votes cannot be changed once cast
- Sessions can be paused but not deleted
- Results are immutable once finalized

## Interface Validation

- [x] External functions ≤ 7 (6 core + batch operations)
- [x] Clear user journeys defined
- [x] Gas costs considered (organization pays)
- [x] Batch operations supported
- [x] Error handling defined

## Function Signatures (Draft)

```solidity
// Organization Functions
function createVotingSession(
    string[] calldata questions,
    bool[] calldata isPrivate,
    uint256 duration
) external returns (uint256 sessionId);

function pauseSession(uint256 sessionId) external;

function finalizeSession(
    uint256 sessionId,
    bytes32 resultsHash
) external;

function addMembers(address[] calldata members) external;

// Member Functions
function castVote(
    uint256 sessionId,
    uint256 questionId,
    uint8 vote // 0=abstain, 1=yes, 2=no
) external;

function batchVote(
    uint256 sessionId,
    uint256[] calldata questionIds,
    uint8[] calldata votes
) external;

// View Functions
function getSessionInfo(uint256 sessionId) external view returns (SessionInfo memory);
function getVoteCounts(uint256 sessionId, uint256 questionId) external view returns (VoteCounts memory);
function isMember(address member) external view returns (bool);
```



