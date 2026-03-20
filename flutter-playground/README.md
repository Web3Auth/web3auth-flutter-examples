# MetaMask Embedded Wallets Flutter Playground

[![Web3Auth](https://img.shields.io/badge/MetaMask-Embedded_Wallets-blue)](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
[![Flutter](https://img.shields.io/badge/Flutter-SDK-02569B?logo=flutter)](https://flutter.dev)

A comprehensive playground application demonstrating all advanced features of MetaMask Embedded Wallets Flutter SDK. This example showcases whitelabeling, multi-factor authentication (MFA), dApp sharing, wallet services, session management, and more.

## 📝 Features

### Authentication & Security
- **Multiple Login Providers**: Google, Facebook, Twitter, Discord, Apple, Email Passwordless, SMS Passwordless
- **Multi-Factor Authentication (MFA)**: Set up and manage 2FA/MFA for enhanced security
- **Custom Authentication**: JWT-based login with custom providers
- **Session Management**: Configure session duration and persistence

### Blockchain Support
- **EVM Chains**: Ethereum, Polygon, BSC, Arbitrum, Optimism, Avalanche, and more
- **Solana**: Full Solana blockchain support with Ed25519 keys
- **Multi-Chain**: Switch between different blockchain networks
- **Smart Accounts**: Account abstraction integration

### Advanced Features
- **Whitelabeling**: Customize the authentication UI with your brand
- **Wallet Services**: Built-in wallet UI for managing assets
- **DApp Share**: Share sessions across devices and domains
- **Key Export**: Control private key export capabilities
- **Server-Side Verification**: Verify user sessions on your backend

### UI Customization
- **Custom Branding**: Logo, colors, theme customization
- **Language Support**: Multiple language options
- **Modal Customization**: Position, size, and behavior settings
- **Loading Screens**: Custom loading indicators

## 🚀 Getting Started

### Prerequisites

- **Flutter**: 3.0.0 or higher
- **Dart**: 2.18.0 or higher
- **MetaMask Embedded Wallets**: [Dashboard account](https://dashboard.web3auth.io)
- **iOS** (for iOS development):
  - iOS 14+, Xcode 12+, Swift 5.x, CocoaPods
- **Android** (for Android development):
  - API level 26+, compileSdkVersion 34, JDK 11+

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Web3Auth/web3auth-flutter-examples.git
   cd web3auth-flutter-examples/flutter-playground
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

3. **Configure advanced features**:
   - **MFA**: Enable multi-factor authentication
   - **Whitelabel**: Upload logo, set brand colors
   - **Session Management**: Configure session duration
   - **Key Export**: Enable/disable private key export

4. **Configure platform settings**:
   - **iOS**: Allowlist `{bundleId}://auth`
   - **Android**: Allowlist your package name

5. **Get your Client ID** from the dashboard

### Code Configuration

Update the configuration in `lib/main.dart`:

```dart
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'dart:io';

Future<void> initWeb3Auth() async {
  late final Uri redirectUrl;
  
  if (Platform.isAndroid) {
    redirectUrl = Uri.parse('w3a://com.example.playground/auth');
  } else if (Platform.isIOS) {
    redirectUrl = Uri.parse('com.example.playground://auth');
  }

  await Web3AuthFlutter.init(
    Web3AuthOptions(
      clientId: "YOUR_WEB3AUTH_CLIENT_ID",
      network: Network.sapphire_mainnet,
      redirectUrl: redirectUrl,
      // Advanced whitelabel configuration
      whiteLabel: WhiteLabelData(
        appName: "My Crypto App",
        logoLight: "https://example.com/logo-light.png",
        logoDark: "https://example.com/logo-dark.png",
        defaultLanguage: Language.en,
        mode: ThemeModes.auto, // light, dark, or auto
        theme: {
          'primary': '#FF6B6B',
          'onPrimary': '#FFFFFF',
        },
      ),
      // Session management
      sessionTime: 86400, // 24 hours in seconds
      // MFA settings
      mfaSettings: MfaSettings(
        deviceShareFactor: MfaLevel.OPTIONAL,
        backUpShareFactor: MfaLevel.OPTIONAL,
        socialBackupFactor: MfaLevel.OPTIONAL,
        passwordFactor: MfaLevel.OPTIONAL,
      ),
    )
  );
  
  await Web3AuthFlutter.initialize();
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

## 💡 Implementation Examples

### 1. Whitelabel Configuration

```dart
await Web3AuthFlutter.init(
  Web3AuthOptions(
    clientId: "YOUR_CLIENT_ID",
    network: Network.sapphire_mainnet,
    redirectUrl: redirectUrl,
    whiteLabel: WhiteLabelData(
      appName: "My Crypto App",
      appUrl: "https://myapp.com",
      logoLight: "https://myapp.com/logo-light.png",
      logoDark: "https://myapp.com/logo-dark.png",
      defaultLanguage: Language.en, // or ja, ko, de, zh, es, fr, pt, nl
      mode: ThemeModes.dark, // light, dark, or auto
      useLogoLoader: true,
      theme: {
        'primary': '#FF6B6B',
        'onPrimary': '#FFFFFF',
        'error': '#FF5252',
      },
    ),
  )
);
```

### 2. Multi-Factor Authentication (MFA)

```dart
// Enable MFA during login
Future<void> loginWithMFA() async {
  final response = await Web3AuthFlutter.login(
    LoginParams(
      loginProvider: Provider.google,
      mfaLevel: MFALevel.MANDATORY, // NONE, OPTIONAL, MANDATORY, DEFAULT
    )
  );
}

// Launch MFA settings UI
Future<void> setupMFA() async {
  try {
    await Web3AuthFlutter.enableMFA();
    print('MFA setup completed');
  } catch (e) {
    print('MFA setup cancelled or failed: $e');
  }
}

// Check if MFA is enabled for user
Future<bool> isMFAEnabled() async {
  final userInfo = await Web3AuthFlutter.getUserInfo();
  return userInfo.isMfaEnabled;
}
```

### 3. Wallet Services UI

```dart
// Launch wallet services (transaction confirmation, wallet management)
Future<void> launchWalletServices() async {
  try {
    await Web3AuthFlutter.launchWalletServices(
      ChainConfig(
        chainNamespace: ChainNamespace.eip155,
        chainId: "0x1", // Ethereum mainnet
        rpcTarget: "https://rpc.ankr.com/eth",
        displayName: "Ethereum",
        blockExplorerUrl: "https://etherscan.io",
        ticker: "ETH",
        tickerName: "Ethereum",
      ),
    );
  } catch (e) {
    print('Wallet services error: $e');
  }
}

// Request transaction with UI
Future<String> sendTransactionWithUI(String txData) async {
  final result = await Web3AuthFlutter.request(
    ChainConfig(
      chainNamespace: ChainNamespace.eip155,
      chainId: "0x1",
      rpcTarget: "https://rpc.ankr.com/eth",
    ),
    "eth_sendTransaction",
    [txData],
  );
  return result;
}
```

### 4. DApp Share (Multi-Device Sessions)

```dart
// Login with dApp share enabled
Future<void> loginWithDappShare() async {
  final response = await Web3AuthFlutter.login(
    LoginParams(
      loginProvider: Provider.google,
      dappShare: "YOUR_DAPP_SHARE", // Optional: pass previous share
    )
  );
  
  // Save dappShare for cross-device usage
  final dappShare = response.dappShare;
  // Store securely for use on other devices
}
```

### 5. Session Management

```dart
// Check for existing session
Future<bool> hasActiveSession() async {
  try {
    final privateKey = await Web3AuthFlutter.getPrivKey();
    return privateKey.isNotEmpty;
  } catch (e) {
    return false;
  }
}

// Get session information
Future<void> getSessionInfo() async {
  final userInfo = await Web3AuthFlutter.getUserInfo();
  print('User ID: ${userInfo.id}');
  print('Email: ${userInfo.email}');
  print('Name: ${userInfo.name}');
  print('Profile Image: ${userInfo.profileImage}');
  print('Verifier: ${userInfo.verifier}');
  print('Verifier ID: ${userInfo.verifierId}');
  print('Type of Login: ${userInfo.typeOfLogin}');
  print('MFA Enabled: ${userInfo.isMfaEnabled}');
}

// Logout
Future<void> logout() async {
  await Web3AuthFlutter.logout();
}
```

### 6. Multi-Chain Support

```dart
// Get private key for different chains
Future<void> getKeysForDifferentChains() async {
  // EVM chains (Ethereum, Polygon, BSC, etc.)
  final evmPrivateKey = await Web3AuthFlutter.getPrivKey();
  
  // Solana
  final solanaPrivateKey = await Web3AuthFlutter.getED25519PrivKey();
}

// Configure chain
ChainConfig getChainConfig(String chainName) {
  switch (chainName) {
    case 'ethereum':
      return ChainConfig(
        chainNamespace: ChainNamespace.eip155,
        chainId: "0x1",
        rpcTarget: "https://rpc.ankr.com/eth",
        displayName: "Ethereum Mainnet",
        blockExplorerUrl: "https://etherscan.io",
        ticker: "ETH",
        tickerName: "Ethereum",
      );
    case 'polygon':
      return ChainConfig(
        chainNamespace: ChainNamespace.eip155,
        chainId: "0x89",
        rpcTarget: "https://rpc.ankr.com/polygon",
        displayName: "Polygon Mainnet",
        blockExplorerUrl: "https://polygonscan.com",
        ticker: "MATIC",
        tickerName: "Polygon",
      );
    case 'solana':
      return ChainConfig(
        chainNamespace: ChainNamespace.solana,
        chainId: "0x1",
        rpcTarget: "https://api.mainnet-beta.solana.com",
        displayName: "Solana Mainnet",
        blockExplorerUrl: "https://explorer.solana.com",
        ticker: "SOL",
        tickerName: "Solana",
      );
    default:
      throw Exception('Unsupported chain');
  }
}
```

### 7. Server-Side Verification

```dart
// Get ID token for backend verification
Future<String> getIdToken() async {
  final userInfo = await Web3AuthFlutter.getUserInfo();
  return userInfo.idToken ?? '';
}

// Verify on your backend
// The ID token is a JWT signed by Web3Auth
// Verify it using Web3Auth's JWKS endpoint
// See: https://docs.metamask.io/embedded-wallets/features/server-side-verification/
```

### 8. Custom Authentication (JWT)

```dart
Future<void> loginWithCustomJWT(String jwtToken) async {
  final response = await Web3AuthFlutter.login(
    LoginParams(
      loginProvider: Provider.jwt,
      extraLoginOptions: ExtraLoginOptions(
        id_token: jwtToken,
        verifierIdField: 'sub', // or email, depending on your JWT
        domain: 'your-domain.com',
      ),
    )
  );
}
```

## 🎨 Customization Options

### Theme Configuration

```dart
theme: {
  'primary': '#FF6B6B',           // Primary brand color
  'onPrimary': '#FFFFFF',         // Text on primary color
  'error': '#FF5252',             // Error color
  'onError': '#FFFFFF',           // Text on error color
  'success': '#4CAF50',           // Success color
  'background': '#FFFFFF',        // Background color
  'surface': '#F5F5F5',           // Surface color
  'onSurface': '#000000',         // Text on surface
}
```

### Language Options

Available languages:
- `Language.en` - English
- `Language.ja` - Japanese
- `Language.ko` - Korean
- `Language.de` - German
- `Language.zh` - Chinese
- `Language.es` - Spanish
- `Language.fr` - French
- `Language.pt` - Portuguese
- `Language.nl` - Dutch

### MFA Levels

- `MFALevel.NONE` - No MFA
- `MFALevel.OPTIONAL` - User can choose to enable MFA
- `MFALevel.MANDATORY` - MFA required for all users
- `MFALevel.DEFAULT` - Follow dashboard settings (shows MFA screen every 3rd login)

## 🔒 Security Features

- **Non-Custodial**: Keys managed using Shamir Secret Sharing
- **MFA Support**: Multiple authentication factors
- **Session Control**: Configurable session duration
- **Key Export Control**: Dashboard toggle for key export
- **Server-Side Verification**: JWT-based backend verification
- **Secure Storage**: Platform-native secure storage

## 📚 Resources

### Documentation
- [MetaMask Embedded Wallets Docs](https://docs.metamask.io/embedded-wallets/)
- [Flutter SDK Reference](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
- [Advanced Configuration](https://docs.metamask.io/embedded-wallets/sdk/flutter/advanced/)
- [Whitelabel Guide](https://docs.metamask.io/embedded-wallets/sdk/flutter/advanced/whitelabel/)
- [MFA Guide](https://docs.metamask.io/embedded-wallets/sdk/flutter/advanced/mfa/)
- [DApp Share Guide](https://docs.metamask.io/embedded-wallets/sdk/flutter/advanced/dapp-share/)

### SDK & Packages
- [web3auth_flutter on pub.dev](https://pub.dev/packages/web3auth_flutter)
- [GitHub Repository](https://github.com/Web3Auth/web3auth-flutter-sdk)
- [Release Notes](https://github.com/Web3Auth/web3auth-flutter-sdk/releases)

### Community & Support
- [MetaMask Builder Hub](https://builder.metamask.io/c/embedded-wallets/5)
- [Discord Community](https://discord.gg/web3auth)
- [GitHub Issues](https://github.com/Web3Auth/web3auth-flutter-examples/issues)

## 🤝 Support

Need help? Reach out through:
- [Builder Hub Community](https://builder.metamask.io/c/embedded-wallets/5)
- [GitHub Issues](https://github.com/Web3Auth/web3auth-flutter-examples/issues)
- [Discord](https://discord.gg/web3auth)

## 📄 License

This example is available under the MIT License. See the [LICENSE](../../LICENSE) file for more info.
