# MetaMask Embedded Wallets Flutter - Solana Example

[![Web3Auth](https://img.shields.io/badge/MetaMask-Embedded_Wallets-blue)](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
[![Solana](https://img.shields.io/badge/Solana-Blockchain-9945FF?logo=solana)](https://solana.com)
[![Flutter](https://img.shields.io/badge/Flutter-SDK-02569B?logo=flutter)](https://flutter.dev)

This example demonstrates how to integrate MetaMask Embedded Wallets with Solana blockchain in a Flutter application. It showcases social authentication combined with Solana wallet operations including SOL transfers, SPL token management, and NFT interactions.

## 📝 Features

- **Social Authentication**: Google, Facebook, Twitter, Discord, Apple, and more
- **Solana Wallet**: Automatic Ed25519 Solana wallet creation
- **SOL Operations**: Check balance, send SOL, request airdrops (devnet/testnet)
- **SPL Token Support**: Token balances, transfers, and token account management
- **NFT Support**: View and manage Solana NFTs
- **Secure Key Management**: Non-custodial Ed25519 key management
- **Cross-Platform**: Single codebase for iOS and Android
- **Devnet & Mainnet**: Easily switch between Solana networks

## 🚀 Getting Started

### Prerequisites

- **Flutter**: 3.0.0 or higher
- **Dart**: 2.18.0 or higher
- **MetaMask Embedded Wallets**: [Dashboard account](https://dashboard.web3auth.io)
- **Solana Knowledge**: Basic understanding of Solana blockchain
- **iOS** (for iOS development):
  - iOS 14+, Xcode 12+, Swift 5.x, CocoaPods
- **Android** (for Android development):
  - API level 26+, compileSdkVersion 34, JDK 11+

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Web3Auth/web3auth-flutter-examples.git
   cd web3auth-flutter-examples/flutter-solana-example
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **iOS Setup** (for iOS development):
   ```bash
   cd ios && pod install && cd ..
   ```

### Dashboard Configuration

1. **Create a project** on the [Embedded Wallets Dashboard](https://dashboard.web3auth.io)

2. **Choose your network**:
   - **Sapphire Devnet**: For development/testing
   - **Sapphire Mainnet**: For production

3. **Configure platform settings**:
   - **iOS**: Allowlist `{bundleId}://auth` (e.g., `com.example.solanaapp://auth`)
   - **Android**: Allowlist your package name and configure deep link scheme

4. **Get your Client ID** from the dashboard

### Code Configuration

Update the configuration in `lib/main.dart`:

```dart
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'dart:io';

Future<void> initWeb3Auth() async {
  late final Uri redirectUrl;
  
  if (Platform.isAndroid) {
    redirectUrl = Uri.parse('w3a://com.example.solanaapp/auth');
  } else if (Platform.isIOS) {
    redirectUrl = Uri.parse('com.example.solanaapp://auth');
  }

  await Web3AuthFlutter.init(
    Web3AuthOptions(
      clientId: "YOUR_WEB3AUTH_CLIENT_ID",
      network: Network.sapphire_mainnet, // or Network.sapphire_devnet
      redirectUrl: redirectUrl,
    )
  );
  
  await Web3AuthFlutter.initialize();
}
```

Configure Solana network in `lib/config/solana_config.dart`:

```dart
class SolanaConfig {
  // Solana Devnet (for testing)
  static const String devnetRpcUrl = 'https://api.devnet.solana.com';
  
  // Solana Mainnet (for production)
  static const String mainnetRpcUrl = 'https://api.mainnet-beta.solana.com';
  
  // Or use a dedicated RPC provider for better performance
  // static const String mainnetRpcUrl = 'https://solana-mainnet.g.alchemy.com/v2/YOUR_API_KEY';
  
  // Current environment
  static const bool useDevnet = true; // Set to false for mainnet
  
  static String get rpcUrl => useDevnet ? devnetRpcUrl : mainnetRpcUrl;
}
```

### Running the App

```bash
# Run in debug mode
flutter run

# Build for release
flutter build ios  # For iOS
flutter build apk  # For Android
```

## 💡 Implementation Details

### Project Structure

```
lib/
├── main.dart              # Entry point & initialization
├── config/
│   └── solana_config.dart # Solana network configuration
├── services/
│   ├── web3auth_service.dart # Web3Auth operations
│   └── solana_service.dart   # Solana blockchain operations
└── screens/
    ├── home.dart          # Home screen with wallet info
    └── login.dart         # Login screen
```

### Core Implementation

#### 1. Initialize Web3Auth

```dart
import 'package:web3auth_flutter/web3auth_flutter.dart';

Future<void> initWeb3Auth() async {
  // ... (see Code Configuration section above)
}
```

#### 2. Implement Authentication

```dart
// Login with Google
Future<void> login() async {
  try {
    final Web3AuthResponse response = await Web3AuthFlutter.login(
      LoginParams(
        loginProvider: Provider.google,
        mfaLevel: MFALevel.NONE,
      )
    );
    
    print('User logged in: ${response.userInfo?.email}');
  } catch (e) {
    print('Login error: $e');
  }
}

// Logout
Future<void> logout() async {
  await Web3AuthFlutter.logout();
}
```

#### 3. Get Solana Private Key (Ed25519)

```dart
// IMPORTANT: For Solana, use getED25519PrivKey(), not getPrivKey()
Future<String> getSolanaPrivateKey() async {
  final privateKeyHex = await Web3AuthFlutter.getED25519PrivKey();
  return privateKeyHex;
}
```

#### 4. Create Solana Wallet

```dart
import 'package:solana/solana.dart';
import 'dart:typed_data';

Future<Ed25519HDKeyPair> getSolanaKeyPair() async {
  // Get Ed25519 private key from Web3Auth
  final privateKeyHex = await Web3AuthFlutter.getED25519PrivKey();
  
  // Convert hex to bytes
  final privateKeyBytes = Uint8List.fromList(
    List<int>.generate(
      privateKeyHex.length ~/ 2,
      (i) => int.parse(privateKeyHex.substring(i * 2, i * 2 + 2), radix: 16),
    ),
  );
  
  // Create KeyPair
  final keyPair = await Ed25519HDKeyPair.fromPrivateKeyBytes(
    privateKey: privateKeyBytes,
  );
  
  return keyPair;
}
```

#### 5. Get Solana Address

```dart
Future<String> getSolanaAddress() async {
  final keyPair = await getSolanaKeyPair();
  return keyPair.address;
}
```

#### 6. Get SOL Balance

```dart
import 'package:solana/solana.dart';

Future<double> getBalance() async {
  final keyPair = await getSolanaKeyPair();
  
  // Create Solana client
  final client = SolanaClient(
    rpcUrl: Uri.parse(SolanaConfig.rpcUrl),
    websocketUrl: Uri.parse(
      SolanaConfig.rpcUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://'),
    ),
  );
  
  // Get balance
  final balance = await client.rpcClient.getBalance(keyPair.address);
  
  // Convert lamports to SOL (1 SOL = 1,000,000,000 lamports)
  final solBalance = balance.value / 1e9;
  
  return solBalance;
}
```

#### 7. Request Airdrop (Devnet/Testnet Only)

```dart
Future<String> requestAirdrop() async {
  final keyPair = await getSolanaKeyPair();
  
  final client = SolanaClient(
    rpcUrl: Uri.parse(SolanaConfig.devnetRpcUrl),
    websocketUrl: Uri.parse('wss://api.devnet.solana.com'),
  );
  
  // Request 1 SOL airdrop
  final signature = await client.rpcClient.requestAirdrop(
    address: keyPair.address,
    lamports: 1000000000, // 1 SOL
  );
  
  print('Airdrop signature: $signature');
  return signature;
}
```

#### 8. Send SOL Transaction

```dart
Future<String> sendSol(String recipientAddress, double amount) async {
  final keyPair = await getSolanaKeyPair();
  
  final client = SolanaClient(
    rpcUrl: Uri.parse(SolanaConfig.rpcUrl),
    websocketUrl: Uri.parse(
      SolanaConfig.rpcUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://'),
    ),
  );
  
  // Convert SOL to lamports
  final lamports = (amount * 1e9).toInt();
  
  // Create and send transaction
  final signature = await client.transferLamports(
    source: keyPair,
    destination: Ed25519HDPublicKey.fromBase58(recipientAddress),
    lamports: lamports,
  );
  
  print('Transaction signature: $signature');
  return signature;
}
```

#### 9. Get SPL Token Balance

```dart
import 'package:solana/solana.dart';

Future<double> getTokenBalance(String tokenMintAddress) async {
  final keyPair = await getSolanaKeyPair();
  
  final client = SolanaClient(
    rpcUrl: Uri.parse(SolanaConfig.rpcUrl),
    websocketUrl: Uri.parse(
      SolanaConfig.rpcUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://'),
    ),
  );
  
  // Get token accounts for the wallet
  final tokenAccounts = await client.rpcClient.getTokenAccountsByOwner(
    keyPair.address,
    TokenAccountsFilter.byMint(tokenMintAddress),
    encoding: Encoding.jsonParsed,
  );
  
  if (tokenAccounts.value.isEmpty) {
    return 0.0;
  }
  
  // Parse token balance
  final accountInfo = tokenAccounts.value.first.account.data;
  if (accountInfo is ParsedAccountData) {
    final tokenAmount = accountInfo.parsed['info']['tokenAmount'];
    return double.parse(tokenAmount['uiAmountString']);
  }
  
  return 0.0;
}
```

#### 10. Get All NFTs (Metaplex)

```dart
Future<List<String>> getNFTs() async {
  final keyPair = await getSolanaKeyPair();
  
  final client = SolanaClient(
    rpcUrl: Uri.parse(SolanaConfig.rpcUrl),
    websocketUrl: Uri.parse(
      SolanaConfig.rpcUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://'),
    ),
  );
  
  // Get all token accounts
  final tokenAccounts = await client.rpcClient.getTokenAccountsByOwner(
    keyPair.address,
    TokenAccountsFilter.byProgramId(TokenProgram.programId),
    encoding: Encoding.jsonParsed,
  );
  
  // Filter for NFTs (amount = 1, decimals = 0)
  List<String> nftMints = [];
  
  for (var account in tokenAccounts.value) {
    if (account.account.data is ParsedAccountData) {
      final data = account.account.data as ParsedAccountData;
      final tokenAmount = data.parsed['info']['tokenAmount'];
      
      if (tokenAmount['decimals'] == 0 && 
          tokenAmount['amount'] == '1') {
        // This is likely an NFT
        nftMints.add(data.parsed['info']['mint']);
      }
    }
  }
  
  return nftMints;
}
```

## 🔒 Security Considerations

- **Ed25519 Keys**: Solana uses Ed25519 curve, not secp256k1 - use `getED25519PrivKey()`
- **Non-Custodial**: Private keys managed using Shamir Secret Sharing
- **Network Consistency**: Never change Client ID or Sapphire network in production
- **Devnet vs Mainnet**: Always test on devnet before deploying to mainnet
- **RPC Rate Limits**: Use dedicated RPC providers (Alchemy, QuickNode, Helius) for production
- **Transaction Fees**: Ensure wallet has sufficient SOL for transaction fees

## 🛠️ Troubleshooting

### Common Issues

**Problem**: Different wallet address than expected

**Solution**:
- Ensure you're using `getED25519PrivKey()` not `getPrivKey()`
- Verify you're using the same Client ID and network

**Problem**: Airdrop fails

**Solutions**:
- Airdrops only work on devnet/testnet
- Rate limits: Wait a few minutes between airdrop requests
- Use alternative devnet/testnet faucets

**Problem**: Transaction fails with "insufficient funds"

**Solutions**:
- Check SOL balance for transaction fees (~0.000005 SOL per signature)
- Request devnet airdrop or transfer SOL from another wallet

**Problem**: Token balance shows 0 but tokens exist

**Solutions**:
- Verify token mint address is correct
- Check that token account exists for the wallet
- Ensure using correct Solana network (devnet vs mainnet)

**Problem**: RPC errors or slow responses

**Solutions**:
- Use dedicated RPC provider (Alchemy, QuickNode, Helius) instead of public endpoints
- Implement retry logic with exponential backoff
- Check RPC provider status page

## 📚 Resources

### Documentation
- [MetaMask Embedded Wallets Docs](https://docs.metamask.io/embedded-wallets/)
- [Flutter SDK Reference](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
- [Solana Documentation](https://docs.solana.com/)
- [Solana Cookbook](https://solanacookbook.com/)
- [Metaplex Documentation](https://docs.metaplex.com/)

### SDK & Packages
- [web3auth_flutter on pub.dev](https://pub.dev/packages/web3auth_flutter)
- [solana on pub.dev](https://pub.dev/packages/solana)
- [GitHub Repository](https://github.com/Web3Auth/web3auth-flutter-sdk)

### Solana Tools
- [Solana Explorer](https://explorer.solana.com/)
- [Solana Devnet Faucet](https://faucet.solana.com/)
- [SPL Token List](https://github.com/solana-labs/token-list)
- [Solana RPC Providers](https://docs.solana.com/cluster/rpc-endpoints)

### Community & Support
- [MetaMask Builder Hub](https://builder.metamask.io/c/embedded-wallets/5)
- [Discord Community](https://discord.gg/web3auth)
- [Solana Discord](https://discord.gg/solana)
- [GitHub Issues](https://github.com/Web3Auth/web3auth-flutter-examples/issues)

## 🤝 Support

Need help? Reach out through:
- [Builder Hub Community](https://builder.metamask.io/c/embedded-wallets/5)
- [GitHub Issues](https://github.com/Web3Auth/web3auth-flutter-examples/issues)
- [Discord](https://discord.gg/web3auth)

## 📄 License

This example is available under the MIT License. See the [LICENSE](../../LICENSE) file for more info.
