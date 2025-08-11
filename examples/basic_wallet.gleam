import bitcoin
import bitcoin.{type Address, type Network, type Transaction, Mainnet, Testnet}
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub type Wallet {
  Wallet(
    private_key: BitArray,
    public_key: BitArray,
    address: Address,
    network: Network,
    balance: Int,
  )
}

pub type WalletError {
  KeyGenerationFailed
  AddressCreationFailed
  TransactionFailed
  InsufficientFunds
}

pub fn main() -> Nil {
  io.println("=== Basic Bitcoin Wallet Example ===")
  io.println("")
  
  // Create a new wallet
  case create_wallet(Testnet) {
    Ok(wallet) -> {
      display_wallet_info(wallet)
      
      // Demonstrate address generation for different networks
      io.println("\n--- Network Address Comparison ---")
      demonstrate_network_addresses(wallet.public_key)
      
      // Demonstrate transaction building
      io.println("\n--- Transaction Building ---")
      demonstrate_transaction_building(wallet)
      
      // Demonstrate address validation
      io.println("\n--- Address Validation ---")
      demonstrate_address_validation()
    }
    Error(e) -> {
      io.println("Failed to create wallet: " <> wallet_error_to_string(e))
    }
  }
}

pub fn create_wallet(network: Network) -> Result(Wallet, WalletError) {
  // In a real implementation, you'd generate a secure random private key
  // For this example, we'll use a deterministic key for reproducible results
  let private_key = generate_example_private_key()
  
  case derive_public_key(private_key) {
    Ok(public_key) -> {
      case bitcoin.create_p2pkh_address(public_key, network) {
        Ok(address) -> {
          Ok(Wallet(
            private_key: private_key,
            public_key: public_key,
            address: address,
            network: network,
            balance: 1_000_000, // 0.01 BTC in satoshis for demo
          ))
        }
        Error(_) -> Error(AddressCreationFailed)
      }
    }
    Error(_) -> Error(KeyGenerationFailed)
  }
}

pub fn display_wallet_info(wallet: Wallet) -> Nil {
  io.println("Wallet Information:")
  io.println("Network: " <> network_to_string(wallet.network))
  
  case bitcoin.address_to_string(wallet.address) {
    Ok(addr_str) -> {
      io.println("Address: " <> addr_str)
    }
    Error(_) -> io.println("Address: [encoding error]")
  }
  
  io.println("Public Key: " <> bitcoin.hex_encode(wallet.public_key))
  io.println("Private Key: " <> bitcoin.hex_encode(wallet.private_key) <> " (NEVER share this!)")
  io.println("Balance: " <> format_satoshis(wallet.balance) <> " BTC")
}

pub fn demonstrate_network_addresses(public_key: BitArray) -> Nil {
  let networks = [
    #(Mainnet, "Mainnet"),
    #(Testnet, "Testnet"),
    #(bitcoin.Signet, "Signet"),
    #(bitcoin.Regtest, "Regtest"),
  ]
  
  list.each(networks, fn(network_info) {
    let #(network, name) = network_info
    
    // P2PKH addresses
    case bitcoin.create_p2pkh_address(public_key, network) {
      Ok(address) -> {
        case bitcoin.address_to_string(address) {
          Ok(addr_str) -> {
            io.println(name <> " P2PKH: " <> addr_str)
          }
          Error(_) -> io.println(name <> " P2PKH: [encoding error]")
        }
      }
      Error(_) -> io.println(name <> " P2PKH: [creation error]")
    }
    
    // P2WPKH addresses
    case bitcoin.create_p2wpkh_address(public_key, network) {
      Ok(address) -> {
        case bitcoin.address_to_string(address) {
          Ok(addr_str) -> {
            io.println(name <> " P2WPKH: " <> addr_str)
          }
          Error(_) -> io.println(name <> " P2WPKH: [encoding error]")
        }
      }
      Error(_) -> io.println(name <> " P2WPKH: [creation error]")
    }
  })
}

pub fn demonstrate_transaction_building(wallet: Wallet) -> Nil {
  io.println("Building a simple transaction...")
  
  // Create a new transaction
  let tx = bitcoin.new_transaction()
  
  // Add a dummy input (previous transaction output)
  let prev_txid = generate_example_txid()
  let script_sig = [] // Empty for this example
  let tx = bitcoin.add_input(tx, prev_txid, 0, script_sig, 0xffffffff)
  
  // Add output to send 0.005 BTC to another address
  let recipient_pubkey = generate_recipient_public_key()
  case bitcoin.create_p2pkh_address(recipient_pubkey, wallet.network) {
    Ok(recipient_address) -> {
      case bitcoin.address_to_string(recipient_address) {
        Ok(recipient_addr_str) -> {
          io.println("Sending to: " <> recipient_addr_str)
          
          let recipient_hash = bitcoin.hash160(recipient_pubkey)
          let output_script = bitcoin.p2pkh_script(recipient_hash)
          let tx = bitcoin.add_output(tx, 500_000, output_script) // 0.005 BTC
          
          // Add change output back to our wallet
          let our_hash = bitcoin.hash160(wallet.public_key)
          let change_script = bitcoin.p2pkh_script(our_hash)
          let tx = bitcoin.add_output(tx, 490_000, change_script) // 0.0049 BTC (0.0001 BTC fee)
          
          // Serialize and display transaction
          case bitcoin.serialize_transaction(tx) {
            Ok(serialized) -> {
              let hex_tx = bitcoin.hex_encode(serialized)
              io.println("Transaction size: " <> string.inspect(bitcoin.hex_encode(serialized) |> string.length() |> fn(x) { x / 2 }) <> " bytes")
              io.println("Transaction hex: " <> hex_tx)
              
              case bitcoin.transaction_hash(tx) {
                Ok(txid) -> {
                  io.println("Transaction ID: " <> txid)
                }
                Error(_) -> io.println("Failed to calculate transaction ID")
              }
            }
            Error(_) -> io.println("Failed to serialize transaction")
          }
        }
        Error(_) -> io.println("Failed to encode recipient address")
      }
    }
    Error(_) -> io.println("Failed to create recipient address")
  }
}

pub fn demonstrate_address_validation() -> Nil {
  let test_addresses = [
    #("1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa", Mainnet, "Valid Bitcoin mainnet address"),
    #("3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy", Mainnet, "Valid P2SH mainnet address"),
    #("bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4", Mainnet, "Valid P2WPKH mainnet address"),
    #("tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx", Testnet, "Valid P2WPKH testnet address"),
    #("invalid_address", Mainnet, "Invalid address"),
    #("1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa", Testnet, "Mainnet address on testnet (should be invalid)"),
  ]
  
  list.each(test_addresses, fn(test_case) {
    let #(address, network, description) = test_case
    let is_valid = bitcoin.validate_address(address, network)
    let status = case is_valid {
      True -> "✓ VALID"
      False -> "✗ INVALID"
    }
    io.println(status <> " - " <> description <> " - " <> address)
  })
}

pub fn send_transaction(
  wallet: Wallet,
  recipient_address: String,
  amount_satoshis: Int,
) -> Result(Transaction, WalletError) {
  case wallet.balance >= amount_satoshis {
    True -> {
      case bitcoin.string_to_address(recipient_address, wallet.network) {
        Ok(_address) -> {
          // In a real implementation, you would:
          // 1. Find unspent transaction outputs (UTXOs)
          // 2. Create inputs from those UTXOs
          // 3. Calculate proper fees
          // 4. Sign the transaction
          // 5. Broadcast to the network
          
          let tx = bitcoin.new_transaction()
          // For this example, we'll just return the empty transaction
          Ok(tx)
        }
        Error(_) -> Error(TransactionFailed)
      }
    }
    False -> Error(InsufficientFunds)
  }
}

// Helper functions

fn generate_example_private_key() -> BitArray {
  // This is NOT a secure way to generate private keys!
  // In production, use cryptographically secure random number generation
  <<0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88,
    0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF, 0x00, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0>>
}

fn generate_recipient_public_key() -> BitArray {
  // Example recipient public key (compressed format)
  <<0x02, 0x89, 0xab, 0xcd, 0xef, 0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef, 0x01, 0x23, 0x45,
    0x67, 0x89, 0xab, 0xcd, 0xef, 0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef, 0x01, 0x23, 0x45, 0x67>>
}

fn generate_example_txid() -> BitArray {
  // Example transaction ID (32 bytes)
  <<0xa1, 0xb2, 0xc3, 0xd4, 0xe5, 0xf6, 0x07, 0x18, 0x29, 0x3a, 0x4b, 0x5c, 0x6d, 0x7e, 0x8f, 0x90,
    0xa1, 0xb2, 0xc3, 0xd4, 0xe5, 0xf6, 0x07, 0x18, 0x29, 0x3a, 0x4b, 0x5c, 0x6d, 0x7e, 0x8f, 0x90>>
}

fn derive_public_key(private_key: BitArray) -> Result(BitArray, WalletError) {
  // In a real implementation, you would use secp256k1 elliptic curve cryptography
  // to derive the public key from the private key
  // For this example, we'll use a mock public key
  Ok(<<0x02, 0x79, 0xbe, 0x66, 0x7e, 0xf9, 0xdc, 0xbb, 0xac, 0x55, 0xa0, 0x62, 0x95, 0xce, 0x87, 0x0b,
       0x07, 0x02, 0x9b, 0xfc, 0xdb, 0x2d, 0xce, 0x28, 0xd9, 0x59, 0xf2, 0x81, 0x5b, 0x16, 0xf8, 0x17, 0x98>>)
}

fn network_to_string(network: Network) -> String {
  case network {
    Mainnet -> "Mainnet"
    Testnet -> "Testnet"  
    bitcoin.Signet -> "Signet"
    bitcoin.Regtest -> "Regtest"
  }
}

fn wallet_error_to_string(error: WalletError) -> String {
  case error {
    KeyGenerationFailed -> "Key generation failed"
    AddressCreationFailed -> "Address creation failed"
    TransactionFailed -> "Transaction failed"
    InsufficientFunds -> "Insufficient funds"
  }
}

fn format_satoshis(satoshis: Int) -> String {
  let btc = satoshis / bitcoin.satoshis_per_bitcoin
  let remaining_satoshis = satoshis % bitcoin.satoshis_per_bitcoin
  let btc_decimal = remaining_satoshis * 100_000_000 / bitcoin.satoshis_per_bitcoin
  string.inspect(btc) <> "." <> pad_zeros(string.inspect(btc_decimal), 8)
}

fn pad_zeros(str: String, target_length: Int) -> String {
  let current_length = string.length(str)
  case current_length >= target_length {
    True -> str
    False -> {
      let zeros_needed = target_length - current_length
      let zeros = string.repeat("0", zeros_needed)
      zeros <> str
    }
  }
}