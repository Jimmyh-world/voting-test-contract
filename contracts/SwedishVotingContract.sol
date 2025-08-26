// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/ISwedishVoting.sol";

/// @title Swedish Association Voting Contract
/// @notice Enables secure, transparent voting for Swedish association governance processes
/// @dev Implements immutable admin access control with wallet-based member identification
/// @dev Storage layout (non-upgradeable design):
/// @dev   Slot 0: _admin (address, immutable)
/// @dev   Slot 1: _sessionCounter (uint256)
/// @dev   Slot 2: _members (mapping(address => bool))
/// @dev   Slot 3+: _sessions (mapping(uint256 => Session))
/// @dev   Slot 4+: _votes (mapping(uint256 => mapping(address => mapping(uint256 => Vote))))
contract SwedishVotingContract is AccessControl, ISwedishVoting {
    // === Constants ===
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 public constant MAX_SESSION_DURATION = 2 hours; // 1-1.5 hours + buffer
    uint256 public constant MIN_SESSION_DURATION = 30 minutes;
    uint256 public constant TIMESTAMP_BUFFER = 30 seconds; // Protection against timestamp manipulation
    uint256 public constant MAX_BATCH_SIZE = 50; // Prevent gas bomb attacks
    uint8 public constant VOTE_ABSTAIN = 0;
    uint8 public constant VOTE_YES = 1;
    uint8 public constant VOTE_NO = 2;

    // === Custom Errors ===
    error NotAdmin();
    error NotMember();
    error SessionNotFound();
    error SessionNotActive();
    error SessionExpired();
    error SessionAlreadyPaused();
    error SessionAlreadyFinalized();
    error InvalidVoteValue();
    error AlreadyVoted();
    error InvalidSessionDuration();
    error InvalidQuestionCount();
    error InvalidMemberArray();
    error ZeroAddress();
    error InvalidResultsHash();
    error DurationOverflow();
    error VoteCountOverflow();
    error InvalidQuestionId();
    error BatchTooLarge();
    error PrivateQuestionResults();
    error InsufficientBalance(uint256 available, uint256 required);

    // Events are defined in ISwedishVoting interface

    // === Data Structures ===
    struct Question {
        bool isPrivate;  // Packed with exists for gas efficiency
        bool exists;
        string text;     // Dynamic content last
    }

    struct Session {
        uint256 startTime;
        uint256 endTime;
        uint256 questionCount;
        bool isPaused;
        bool isFinalized;
        bytes32 resultsHash;
        mapping(uint256 => Question) questions;
        mapping(uint256 => mapping(address => bool)) hasVoted; // questionId => member => hasVoted
        mapping(uint256 => mapping(uint8 => uint256)) voteCounts; // questionId => vote => count
        bool exists;
    }

    struct Vote {
        uint8 vote;
        uint256 timestamp;
    }

    // Data structures are defined in ISwedishVoting interface

    // === Storage ===
    address public immutable admin;
    uint256 private _sessionCounter;
    mapping(address => bool) private _members;
    mapping(uint256 => Session) private _sessions;

    // === Constructor ===
    /// @notice Initialize the voting contract
    /// @param _admin Initial admin address (organization)
    constructor(address _admin) {
        if (_admin == address(0)) revert ZeroAddress();
        
        admin = _admin;
        _grantRole(ADMIN_ROLE, _admin);
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE); // Admin role manages itself
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender); // Deployer gives up control

        emit Deployed(_admin, "1.0.0");
    }

    // === Modifiers ===
    modifier onlyAdmin() {
        if (!hasRole(ADMIN_ROLE, msg.sender)) revert NotAdmin();
        _;
    }

    modifier onlyMember() {
        if (!_members[msg.sender]) revert NotMember();
        _;
    }

    modifier sessionExists(uint256 sessionId) {
        if (!_sessions[sessionId].exists) revert SessionNotFound();
        _;
    }

    modifier sessionActive(uint256 sessionId) {
        Session storage session = _sessions[sessionId];
        if (!session.exists) revert SessionNotFound();
        if (session.isFinalized) revert SessionAlreadyFinalized();
        if (session.isPaused) revert SessionAlreadyPaused();
        if (block.timestamp > session.endTime + TIMESTAMP_BUFFER) revert SessionExpired();
        _;
    }

    modifier validVoteValue(uint8 vote) {
        if (vote > VOTE_NO) revert InvalidVoteValue();
        _;
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
    ) external onlyAdmin returns (uint256 sessionId) {
        // Input validation
        if (questions.length == 0 || questions.length != isPrivate.length) {
            revert InvalidQuestionCount();
        }
        if (duration < MIN_SESSION_DURATION || duration > MAX_SESSION_DURATION) {
            revert InvalidSessionDuration();
        }

        // Create session
        sessionId = ++_sessionCounter;
        Session storage session = _sessions[sessionId];
        
        session.startTime = block.timestamp;
        
        // Overflow protection for duration calculation
        unchecked {
            uint256 endTime = block.timestamp + duration;
            if (endTime < block.timestamp) revert DurationOverflow();
            session.endTime = endTime;
        }
        
        session.questionCount = questions.length;
        session.isPaused = false;
        session.isFinalized = false;
        session.resultsHash = bytes32(0);
        session.exists = true;

        // Add questions
        for (uint256 i = 0; i < questions.length; i++) {
            session.questions[i] = Question({
                text: questions[i],
                isPrivate: isPrivate[i],
                exists: true
            });
        }

        emit VotingSessionCreated(
            sessionId,
            msg.sender,
            questions.length,
            duration,
            block.timestamp
        );
    }

    /// @notice Pause a voting session under extenuating circumstances
    /// @param sessionId ID of the session to pause
    function pauseSession(uint256 sessionId) external onlyAdmin sessionExists(sessionId) {
        Session storage session = _sessions[sessionId];
        if (session.isFinalized) revert SessionAlreadyFinalized();
        if (session.isPaused) revert SessionAlreadyPaused();

        session.isPaused = true;

        emit SessionPaused(sessionId, msg.sender, block.timestamp);
    }

    /// @notice Finalize a voting session and record results hash
    /// @param sessionId ID of the session to finalize
    /// @param resultsHash Hash of the final voting results
    function finalizeSession(
        uint256 sessionId,
        bytes32 resultsHash
    ) external onlyAdmin sessionExists(sessionId) {
        Session storage session = _sessions[sessionId];
        if (session.isFinalized) revert SessionAlreadyFinalized();
        if (resultsHash == bytes32(0)) revert InvalidResultsHash();

        session.isFinalized = true;
        session.resultsHash = resultsHash;

        emit SessionFinalized(sessionId, msg.sender, resultsHash, block.timestamp);
    }

    /// @notice Add verified members to the on-chain registry
    /// @param members Array of member addresses to add
    function addMembers(address[] calldata members) external onlyAdmin {
        if (members.length == 0) revert InvalidMemberArray();

        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == address(0)) revert ZeroAddress();
            _members[members[i]] = true;
        }

        emit MembersAdded(members, msg.sender, block.timestamp);
    }

    // === Member Functions ===
    /// @notice Cast a vote on a specific question
    /// @param sessionId ID of the voting session
    /// @param questionId ID of the question to vote on
    /// @param vote Vote value (0=abstain, 1=yes, 2=no)
    function castVote(
        uint256 sessionId,
        uint256 questionId,
        uint8 vote
    ) external onlyMember sessionActive(sessionId) validVoteValue(vote) {
        Session storage session = _sessions[sessionId];
        
        // Check if question exists and is within bounds
        if (questionId >= session.questionCount) revert InvalidQuestionId();
        if (!session.questions[questionId].exists) revert SessionNotFound();
        
        // Check if already voted
        if (session.hasVoted[questionId][msg.sender]) revert AlreadyVoted();

        // Record vote with overflow protection
        session.hasVoted[questionId][msg.sender] = true;
        
        unchecked {
            uint256 newCount = session.voteCounts[questionId][vote] + 1;
            if (newCount == 0) revert VoteCountOverflow(); // Wrapped around
            session.voteCounts[questionId][vote] = newCount;
        }

        // Privacy-aware event emission
        uint8 emittedVote = session.questions[questionId].isPrivate ? 0 : vote;
        emit VoteCast(sessionId, questionId, msg.sender, emittedVote, block.timestamp);
    }

    /// @notice Vote on multiple questions in a single transaction
    /// @param sessionId ID of the voting session
    /// @param questionIds Array of question IDs to vote on
    /// @param votes Array of vote values corresponding to questionIds
    function batchVote(
        uint256 sessionId,
        uint256[] calldata questionIds,
        uint8[] calldata votes
    ) external onlyMember sessionActive(sessionId) {
        if (questionIds.length == 0 || questionIds.length != votes.length) {
            revert InvalidQuestionCount();
        }
        
        // Prevent gas bomb attacks
        if (questionIds.length > MAX_BATCH_SIZE) revert BatchTooLarge();

        Session storage session = _sessions[sessionId];

        for (uint256 i = 0; i < questionIds.length; i++) {
            uint256 questionId = questionIds[i];
            uint8 vote = votes[i];

            // Validate vote value
            if (vote > VOTE_NO) revert InvalidVoteValue();

            // Check if question exists and is within bounds
            if (questionId >= session.questionCount) revert InvalidQuestionId();
            if (!session.questions[questionId].exists) revert SessionNotFound();

            // Check if already voted
            if (session.hasVoted[questionId][msg.sender]) revert AlreadyVoted();

            // Record vote with overflow protection
            session.hasVoted[questionId][msg.sender] = true;
            
            unchecked {
                uint256 newCount = session.voteCounts[questionId][vote] + 1;
                if (newCount == 0) revert VoteCountOverflow(); // Wrapped around
                session.voteCounts[questionId][vote] = newCount;
            }

            // Privacy-aware event emission
            uint8 emittedVote = session.questions[questionId].isPrivate ? 0 : vote;
            emit VoteCast(sessionId, questionId, msg.sender, emittedVote, block.timestamp);
        }
    }

    // === View Functions ===
    /// @notice Get voting session details
    /// @param sessionId ID of the session
    /// @return Session information
    function getSessionInfo(uint256 sessionId) external view returns (SessionInfo memory) {
        Session storage session = _sessions[sessionId];
        if (!session.exists) revert SessionNotFound();

        return SessionInfo({
            startTime: session.startTime,
            endTime: session.endTime,
            questionCount: session.questionCount,
            isPaused: session.isPaused,
            isFinalized: session.isFinalized,
            resultsHash: session.resultsHash,
            exists: true
        });
    }

    /// @notice Get vote counts for a specific question
    /// @param sessionId ID of the voting session
    /// @param questionId ID of the question
    /// @return Vote counts (abstain, yes, no)
    function getVoteCounts(
        uint256 sessionId,
        uint256 questionId
    ) external view sessionExists(sessionId) returns (VoteCounts memory) {
        Session storage session = _sessions[sessionId];
        
        // Check if question exists and is within bounds
        if (questionId >= session.questionCount) revert InvalidQuestionId();
        if (!session.questions[questionId].exists) revert SessionNotFound();
        
        // Only return counts if question is not private or session is finalized
        if (session.questions[questionId].isPrivate && !session.isFinalized) {
            revert PrivateQuestionResults();
        }

        return VoteCounts({
            abstainCount: session.voteCounts[questionId][VOTE_ABSTAIN],
            yesCount: session.voteCounts[questionId][VOTE_YES],
            noCount: session.voteCounts[questionId][VOTE_NO]
        });
    }

    /// @notice Check if an address is a registered member
    /// @param member Address to check
    /// @return True if the address is a member
    function isMember(address member) external view returns (bool) {
        return _members[member];
    }

    /// @notice Get the total number of voting sessions
    /// @return Total number of sessions created
    function getSessionCount() external view returns (uint256) {
        return _sessionCounter;
    }

    /// @notice Check if a member has voted on a specific question
    /// @param sessionId ID of the voting session
    /// @param questionId ID of the question
    /// @param member Address of the member
    /// @return True if the member has voted on this question
    function hasVoted(
        uint256 sessionId,
        uint256 questionId,
        address member
    ) external view sessionExists(sessionId) returns (bool) {
        return _sessions[sessionId].hasVoted[questionId][member];
    }


}
