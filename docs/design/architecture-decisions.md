# Architecture Decisions: Swedish Association Voting Contract

## Access Control Design

**Admin Authority**:

- Single organization address (Board of Directors/Secretary)
- Immutable after deployment (no transfer of admin rights)
- Represents the legal entity of the Swedish association

**Required Admin Functions**:

1. **createVotingSession** - Critical: Core functionality
2. **pauseSession** - Critical: Emergency control
3. **finalizeSession** - Critical: Result recording
4. **addMembers** - Critical: Member management

**Permission Levels**:

- **Admin**: Organization address (full control)
- **Members**: Registered addresses (voting only)
- **Public**: Anyone (view functions only)

**Permission Transfer Process**:

- **NO TRANSFER**: Admin permissions are immutable
- **Rationale**: Swedish associations have legal governance structures that shouldn't change on-chain
- **Alternative**: If organization changes, deploy new contract

**Immutable Elements**:

- Admin address (organization)
- Core voting logic
- Result recording mechanism
- Member verification process

## Decision Rationale

**Why Single Admin Model**:

- Swedish associations have clear legal governance structures
- Single point of accountability aligns with legal requirements
- Simplicity reduces attack surface and complexity

**Alternatives Considered**:

- **Multi-sig**: Rejected - adds complexity without legal benefit
- **DAO Governance**: Rejected - overkill for simple voting
- **Transferable Admin**: Rejected - creates governance instability

**Security Implications**:

- Single point of failure (mitigated by legal accountability)
- Clear audit trail for all admin actions
- Immutable admin prevents governance attacks

## Admin Function Justification

| Function            | Necessity | Risk Level | Mitigation                      |
| ------------------- | --------- | ---------- | ------------------------------- |
| createVotingSession | Critical  | Low        | Only admin can create           |
| pauseSession        | Critical  | Medium     | Emergency use only              |
| finalizeSession     | Critical  | Low        | Immutable results               |
| addMembers          | Critical  | Medium     | Off-chain verification required |

## Security Considerations

### Admin Protection

- **Immutable Admin**: Cannot be changed after deployment
- **Legal Accountability**: Admin represents legal entity
- **Audit Trail**: All admin actions are logged

### Member Management

- **Off-chain Verification**: Members verified before on-chain addition
- **Non-transferable**: Membership cannot be sold/transferred
- **Batch Operations**: Efficient member addition

### Emergency Controls

- **Pause Functionality**: Emergency stop for crisis situations
- **Limited Scope**: Pause only, no data modification
- **Clear Triggers**: Only for extenuating circumstances

## KISS Compliance

- [x] Single admin model (simplest possible)
- [x] Minimal admin functions (4 essential functions only)
- [x] No complex permission hierarchies
- [x] Immutable admin prevents governance complexity
- [x] Clear legal alignment with Swedish association structure



