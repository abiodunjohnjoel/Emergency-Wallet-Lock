📜 Emergency Wallet Lock Contract

Overview

The Emergency Wallet Lock Contract provides a security mechanism that allows funds to be temporarily frozen in case of suspicious activity. This helps protect user assets by enabling the contract owner to activate an emergency lock, restrict withdrawals, and enforce time-based or permission-based unlocking.

✨ Features

Deposit & Freeze: Users can deposit STX tokens, which remain frozen during an active lock.

Emergency Lock: Owner can activate a lock that prevents withdrawals until conditions are met.

Unlock Mechanisms:

Automatic unlock after a set duration (default: 144 blocks ≈ 24 hours).

Immediate unlock if owner or authorized users approve.

Owner Controls:

Activate/deactivate the emergency lock.

Adjust lock duration.

Grant or revoke user-specific unlock permissions.

Transparency: Read-only functions let anyone check the lock state, balances, permissions, and time remaining until auto-unlock.

⚖️ Public Functions

deposit (amount uint) → Deposit STX into the contract.

activate-emergency-lock → Owner activates lock.

unlock-funds → Unlock funds based on rules (owner, authorized user, or time-based).

grant-unlock-permission (user principal) → Owner grants early unlock rights.

revoke-unlock-permission (user principal) → Owner revokes unlock rights.

deactivate-emergency-lock → Owner disables the emergency lock.

set-lock-duration (duration uint) → Owner sets lock duration in blocks.

📊 Read-only Functions

is-locked → Returns true if emergency lock is active.

get-frozen-balance (user principal) → Returns frozen balance for a user.

has-unlock-permission (user principal) → Checks if user has unlock rights.

get-time-until-unlock → Returns remaining blocks until auto-unlock.

get-contract-status → Provides lock state, timestamp, duration, and current block.

🔒 Security Considerations

Only the contract owner can activate/deactivate locks or change settings.

Funds are safe even under lock—no withdrawals allowed until unlock conditions are met.

Permissions allow flexible emergency recovery while minimizing risks.

🚀 Use Case

This contract is ideal for crypto wallets, exchanges, or custodial services that need an emergency safeguard against hacks, suspicious activity, or compromised keys.