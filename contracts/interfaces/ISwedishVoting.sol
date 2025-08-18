// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title Swedish Voting Contract Interface
/// @notice Interface for the Swedish Association Voting Contract
/// @dev Defines all external functions for integration with other contracts
interface ISwedishVoting {
    // === Events ===
    event VotingSessionCreated(
        uint256 indexed sessionId,
        address indexed admin,
        uint256 questionCount,
        uint256 duration,
        uint256 timestamp
    );

    event VoteCast(
        uint256 indexed sessionId,
        uint256 indexed questionId,
        address indexed member,
        uint8 vote,
        uint256 timestamp
    );

    event SessionPaused(
        uint256 indexed sessionId,
        address indexed admin,
        uint256 timestamp
    );

    event SessionFinalized(
        uint256 indexed sessionId,
        address indexed admin,
        bytes32 resultsHash,
        uint256 timestamp
    );

    event MembersAdded(
        address[] indexed members,
        address indexed admin,
        uint256 timestamp
    );

    event Deployed(address indexed admin, string version);

    // === Data Structures ===
    struct SessionInfo {
        uint256 startTime;
        uint256 endTime;
        uint256 questionCount;
        bool isPaused;
        bool isFinalized;
        bytes32 resultsHash;
        bool exists;
    }

    struct VoteCounts {
        uint256 abstainCount;
        uint256 yesCount;
        uint256 noCount;
    }

    // === Admin Functions ===
    /// @notice Create a new voting session with multiple questions
    /// @param questions Array of question texts
    /// @param isPrivate Array of privacy settings for each question
    /// @param duration Duration of the voting session in seconds
    /// @return sessionId Unique identifier for the created session
    function createVotingSession(
        string[] calldata questions,
        bool[] calldata isPrivate,
        uint256 duration
    ) external returns (uint256 sessionId);

    /// @notice Pause a voting session under extenuating circumstances
    /// @param sessionId ID of the session to pause
    function pauseSession(uint256 sessionId) external;

    /// @notice Finalize a voting session and record results hash
    /// @param sessionId ID of the session to finalize
    /// @param resultsHash Hash of the final voting results
    function finalizeSession(uint256 sessionId, bytes32 resultsHash) external;

    /// @notice Add verified members to the on-chain registry
    /// @param members Array of member addresses to add
    function addMembers(address[] calldata members) external;

    // === Member Functions ===
    /// @notice Cast a vote on a specific question
    /// @param sessionId ID of the voting session
    /// @param questionId ID of the question to vote on
    /// @param vote Vote value (0=abstain, 1=yes, 2=no)
    function castVote(uint256 sessionId, uint256 questionId, uint8 vote) external;

    /// @notice Vote on multiple questions in a single transaction
    /// @param sessionId ID of the voting session
    /// @param questionIds Array of question IDs to vote on
    /// @param votes Array of vote values corresponding to questionIds
    function batchVote(
        uint256 sessionId,
        uint256[] calldata questionIds,
        uint8[] calldata votes
    ) external;

    // === View Functions ===
    /// @notice Get voting session details
    /// @param sessionId ID of the session
    /// @return Session information
    function getSessionInfo(uint256 sessionId) external view returns (SessionInfo memory);

    /// @notice Get vote counts for a specific question
    /// @param sessionId ID of the voting session
    /// @param questionId ID of the question
    /// @return Vote counts (abstain, yes, no)
    function getVoteCounts(uint256 sessionId, uint256 questionId) external view returns (VoteCounts memory);

    /// @notice Check if an address is a registered member
    /// @param member Address to check
    /// @return True if the address is a member
    function isMember(address member) external view returns (bool);

    /// @notice Get the total number of voting sessions
    /// @return Total number of sessions created
    function getSessionCount() external view returns (uint256);

    /// @notice Check if a member has voted on a specific question
    /// @param sessionId ID of the voting session
    /// @param questionId ID of the question
    /// @param member Address of the member
    /// @return True if the member has voted on this question
    function hasVoted(uint256 sessionId, uint256 questionId, address member) external view returns (bool);

    // === Constants ===
    function VOTE_ABSTAIN() external pure returns (uint8);
    function VOTE_YES() external pure returns (uint8);
    function VOTE_NO() external pure returns (uint8);
    function MIN_SESSION_DURATION() external pure returns (uint256);
    function MAX_SESSION_DURATION() external pure returns (uint256);
    function ADMIN_ROLE() external pure returns (bytes32);
    function admin() external view returns (address);
}
