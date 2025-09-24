# StackBridge

A secure cross-chain bridge for Bitcoin on Stacks blockchain, enabling seamless wrapping of sBTC to wBTC.

## Features

- 🔒 Secure locking mechanism for sBTC collateral
- 🔄 Mint and burn wBTC tokens
- ⚡ Atomic operations for safe transfers
- 📊 Balance tracking and viewing functions
- 🛡️ Built-in error handling and refund mechanisms

## Contract Functions

### Public Functions

- `lock(amount: uint)`: Lock sBTC and receive wBTC tokens
- `unlock(amount: uint)`: Burn wBTC tokens to retrieve locked sBTC

### Read-Only Functions

- `get-locked(user: principal)`: Get locked sBTC amount for a user
- `get-wbtc-balance(user: principal)`: Get wBTC balance for a user

## Error Codes

- `ERR-NOT-ENOUGH (u100)`: Insufficient balance or amount
- `ERR-NOT-FOUND (u101)`: User record not found
- `ERR-NOT-OWNER (u102)`: Not the owner of the assets

## Development

### Prerequisites

- Clarinet
- Node.js
- Stacks Wallet for testing

### Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/StackBridge.git

# Install dependencies
npm install

# Run tests
clarinet test
```

## Security

- All operations are atomic
- Failed transactions are automatically refunded
- Balance tracking prevents double-spending
- Built with Clarity v2 safety features

