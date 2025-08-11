# Bitcoin Library Examples

This directory contains practical examples demonstrating how to use the Gleam Bitcoin library. These examples are designed to help developers understand the core concepts and get started with Bitcoin development in Gleam.

## Available Examples

### 1. Basic Wallet (`basic_wallet.gleam`)

A comprehensive example demonstrating the fundamentals of Bitcoin wallet operations including:

- **Wallet Creation**: Generate private/public key pairs and create addresses
- **Multi-Network Support**: Create addresses for different Bitcoin networks (Mainnet, Testnet, Signet, Regtest)
- **Address Types**: Generate different types of Bitcoin addresses (P2PKH, P2WPKH)
- **Transaction Building**: Construct and serialize Bitcoin transactions
- **Address Validation**: Validate Bitcoin addresses for different networks
- **Balance Management**: Track wallet balance and format Bitcoin amounts

## Running the Examples

### Prerequisites

1. Make sure you have Gleam installed on your system
2. Ensure you're in the root directory of the gleam-bitcoin project

### Running the Basic Wallet Example

```sh
# From the project root directory
gleam run -m examples/basic_wallet
```

This will execute the basic wallet example and display output showing:

1. **Wallet Information**: Generated address, public key, and balance
2. **Network Address Comparison**: How the same public key generates different addresses on different networks
3. **Transaction Building**: Step-by-step transaction construction and serialization
4. **Address Validation**: Testing various Bitcoin addresses for validity

### Expected Output

When you run the basic wallet example, you should see output similar to:

```
=== Basic Bitcoin Wallet Example ===

Wallet Information:
Network: Testnet
Address: mhWxJpB6BbxFjZN5fKH7HMXNGXcHGvQBu8
Public Key: 027950667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798
Private Key: 123456789abcdef0112233445566778899aabbccddeeff00123456789abcdef0 (NEVER share this!)
Balance: 0.01000000 BTC

--- Network Address Comparison ---
Mainnet P2PKH: 1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2
Mainnet P2WPKH: bc1q0c6dvuv7a3m3q88zwxvp7plfj8lmngh4kqagly
Testnet P2PKH: mhWxJpB6BbxFjZN5fKH7HMXNGXcHGvQBu8
Testnet P2WPKH: tb1q0c6dvuv7a3m3q88zwxvp7plfj8lmngh4kxykjj
Signet P2PKH: mhWxJpB6BbxFjZN5fKH7HMXNGXcHGvQBu8
Signet P2WPKH: tb1q0c6dvuv7a3m3q88zwxvp7plfj8lmngh4kxykjj
Regtest P2PKH: mhWxJpB6BbxFjZN5fKH7HMXNGXcHGvQBu8
Regtest P2WPKH: bcrt1q0c6dvuv7a3m3q88zwxvp7plfj8lmngh4kxykjj

--- Transaction Building ---
Building a simple transaction...
Sending to: mshCEcmCqB5fk9CvA9Vqo7Dk7eTdVK1N2o
Transaction size: 226 bytes
Transaction hex: 01000000010a1b2c3d4e5f6071829...
Transaction ID: 7d2b5e8f1a3c6d9e2f4b8c1a5d7e9f2b4c8a1d5e7f9b2c4a8d1e5f7b9c2a4d8e

--- Address Validation ---
✓ VALID - Valid Bitcoin mainnet address - 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa
✓ VALID - Valid P2SH mainnet address - 3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy
✓ VALID - Valid P2WPKH mainnet address - bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4
✓ VALID - Valid P2WPKH testnet address - tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx
✗ INVALID - Invalid address - invalid_address
✗ INVALID - Mainnet address on testnet (should be invalid) - 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa
```

## Key Learning Points

### 1. Wallet Structure
The example demonstrates how to structure a basic Bitcoin wallet with:
- Private key storage (keep this secure!)
- Public key derivation
- Address generation
- Balance tracking

### 2. Network Considerations
Bitcoin has multiple networks, each with different address formats:
- **Mainnet**: Real Bitcoin network with real value
- **Testnet**: Testing network with test coins (no real value)
- **Signet**: Alternative test network with more predictable block times
- **Regtest**: Private test network for development

### 3. Address Types
The example shows different Bitcoin address types:
- **P2PKH** (Legacy): Starts with '1' on mainnet, 'm' or 'n' on testnet
- **P2WPKH** (SegWit v0): Starts with 'bc1' on mainnet, 'tb1' on testnet
- **P2SH** (Script Hash): Starts with '3' on mainnet, '2' on testnet

### 4. Transaction Structure
A Bitcoin transaction contains:
- **Inputs**: References to previous transaction outputs being spent
- **Outputs**: New transaction outputs being created
- **Scripts**: Programs that define spending conditions
- **Fees**: The difference between input and output values

## Security Considerations

⚠️ **Important Security Notes:**

1. **Private Keys**: Never share or expose private keys. The example shows them for educational purposes only.

2. **Random Number Generation**: The example uses deterministic keys for reproducibility. In production, always use cryptographically secure random number generation.

3. **Key Storage**: In real applications, store private keys securely using hardware security modules, encrypted storage, or specialized key management systems.

4. **Network Selection**: Always verify you're using the correct network (mainnet vs testnet) to avoid sending real Bitcoin to test addresses.

## Extending the Examples

You can extend these examples by:

1. **Adding More Address Types**: Implement P2SH, P2WSH, and P2TR address generation
2. **UTXO Management**: Add functionality to track and manage unspent transaction outputs
3. **Fee Calculation**: Implement proper fee estimation based on network conditions
4. **Signature Creation**: Add transaction signing capabilities
5. **Mnemonic Seeds**: Implement BIP39 mnemonic phrase generation and recovery

## Common Issues and Solutions

### Build Errors
If you encounter build errors:
```sh
# Clean and rebuild
gleam clean
gleam build
```

### Import Errors
Make sure you're running the example from the project root directory:
```sh
# From /path/to/gleam-bitcoin
gleam run -m examples/basic_wallet
```

### Missing Dependencies
Ensure all dependencies are installed:
```sh
gleam deps download
```

## Further Reading

- [Bitcoin Developer Guide](https://developer.bitcoin.org/devguide/)
- [BIP (Bitcoin Improvement Proposals)](https://github.com/bitcoin/bips)
- [Mastering Bitcoin](https://github.com/bitcoinbook/bitcoinbook) - Free online book
- [Bitcoin Script](https://en.bitcoin.it/wiki/Script) - Understanding Bitcoin scripting

## Contributing

To add more examples:

1. Create a new `.gleam` file in the `examples/` directory
2. Follow the existing code style and structure
3. Add documentation explaining the example's purpose
4. Update this README to include your new example
5. Test your example thoroughly before submitting

Examples should focus on practical, real-world use cases that help developers understand how to use the Bitcoin library effectively.