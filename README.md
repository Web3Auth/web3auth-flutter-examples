# MetaMask Embedded Wallets Flutter SDK Examples

[![Web3Auth](https://img.shields.io/badge/MetaMask-Embedded_Wallets-blue)](https://docs.metamask.io/embedded-wallets/)
[![Flutter](https://img.shields.io/badge/Flutter-SDK-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)

This repository contains comprehensive Flutter examples demonstrating the integration of MetaMask Embedded Wallets (formerly Web3Auth Plug and Play) SDK. These examples showcase seamless authentication experiences with social logins, custom authentication, and blockchain interactions for both iOS and Android platforms.

## 🌟 Key Features

- **Social Authentication**: Google, Facebook, Twitter, Discord, Apple, and more
- **Custom Authentication**: Firebase, Auth0, and JWT-based authentication
- **Grouped Connections**: Same wallet across multiple authentication methods
- **Multi-Factor Authentication (MFA)**: Enhanced security options
- **Blockchain Agnostic**: Full support for EVM chains, Solana, and others
- **Cross-Platform**: Unified codebase for iOS and Android
- **Non-Custodial**: Fully decentralized key management using Shamir Secret Sharing

## 📱 Available Examples

### Plug and Play (PnP) SDK Examples

These examples use the latest MetaMask Embedded Wallets SDK (`web3auth_flutter ^7.0.0`):

| Example | Description | Features |
|---------|-------------|----------|
| [**flutter-quick-start**](./flutter-quick-start) | Basic integration with social logins | EVM chains, social authentication |
| [**flutter-firebase-example**](./flutter-firebase-example) | Custom auth with Firebase | Firebase Auth, JWT verification |
| [**flutter-auth0-example**](./flutter-auth0-example) | Custom auth with Auth0 | Auth0 integration, OAuth 2.0 |
| [**flutter-aggregate-verifier-example**](./flutter-aggregate-verifier-example) | Grouped connections | Same wallet across multiple providers |
| [**flutter-solana-example**](./flutter-solana-example) | Solana blockchain integration | Solana wallet, SPL tokens |
| [**flutter-playground**](./flutter-playground) | Advanced features showcase | MFA, wallet services, multi-chain |

## What's new in v7

All examples target `web3auth_flutter ^7.0.0` (Android SDK v10 / iOS SDK v12). Key renames from v6:

| v6 | v7 |
|----|-----|
| `Network` | `Web3AuthNetwork` |
| `network:` | `web3AuthNetwork:` |
| `Provider` / `TypeOfLogin` | `AuthConnection` |
| `Provider.jwt` | `AuthConnection.custom` |
| `Web3AuthFlutter.login()` | `Web3AuthFlutter.connectTo()` |
| `loginProvider:` | `authConnection:` |
| `redirectUrl: Uri` | `redirectUrl: String` |
| `loginConfig` | `authConnectionConfig` |
| `verifier` | `authConnectionId` |
| `verifierSubIdentifier` | `groupedAuthConnectionId` |
| `verifierIdField` | `userIdField` |
| `getPrivKey()` | `getPrivateKey()` |
| `getEd25519PrivKey()` | `getEd25519PrivateKey()` |
| `TorusUserInfo` | `UserInfo` |
| `response.privKey` | `response.privateKey` |
| `launchWalletServices(ChainConfig)` | `showWalletUI()` |
| `request(ChainConfig, ...)` | `request(method, params)` |
| SDK `ChainConfig` | `Web3AuthOptions(chains: [Chains(...)])` |

## 🚀 Quick Start

### Prerequisites

- **Flutter** SDK 3.0.0 or higher
- **Dart** 2.18.0 or higher
- **iOS**: iOS 14+, Xcode 12+, Swift 5.x
- **Android**: API level 26+, compileSdkVersion 34
- [MetaMask Embedded Wallets Dashboard](https://dashboard.web3auth.io) account

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Web3Auth/web3auth-flutter-examples.git
   cd web3auth-flutter-examples
   ```

2. **Choose an example**:
   ```bash
   cd flutter-quick-start  # or any other example
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **iOS setup** (if targeting iOS):
   ```bash
   cd ios && pod install && cd ..
   ```

5. **Configure your project**:
   - Create a project on the [Embedded Wallets Dashboard](https://dashboard.web3auth.io)
   - Get your Client ID
   - Choose network: **Sapphire Devnet** (for testing) or **Sapphire Mainnet** (for production)
   - Configure allowlisted URLs and bundle IDs
   - Update the Client ID in the example code

6. **Run the app**:
   ```bash
   flutter run
   ```

## 🔑 Key Concepts

### Network Selection

- **Sapphire Devnet**: For development and testing (allows localhost)
- **Sapphire Mainnet**: For production (does NOT allow localhost)

⚠️ **Critical**: Never change your Client ID or Sapphire network in production - this will change all user wallet addresses permanently.

### Authentication Types

- **Social Logins**: Pre-configured Google, Facebook, Discord, Twitter, Apple, etc.
- **Custom Authentication**: Bring your own JWT provider (Firebase, Auth0, AWS Cognito, etc.)
- **Grouped Connections**: Link multiple login methods to the same wallet address

### Private Key Management

- Uses Shamir Secret Sharing (SSS) for non-custodial key management
- Same user + same config = same wallet address (deterministic)
- Keys are reconstructed from distributed shares - no single party holds the full key

## 📚 Documentation & Resources

### Official Documentation
- [MetaMask Embedded Wallets Docs](https://docs.metamask.io/embedded-wallets/)
- [Flutter SDK Reference](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
- [Dashboard Setup Guide](https://docs.metamask.io/embedded-wallets/dashboard/)
- [Migration Guides](https://docs.metamask.io/embedded-wallets/sdk/flutter/migration-guides/)

### SDK & Package
- [Flutter Package on pub.dev](https://pub.dev/packages/web3auth_flutter)
- [GitHub Repository](https://github.com/Web3Auth/web3auth-flutter-sdk)
- [Release Notes](https://github.com/Web3Auth/web3auth-flutter-sdk/releases)

### Community & Support
- [MetaMask Builder Hub](https://builder.metamask.io/c/embedded-wallets/5)
- [GitHub Issues](https://github.com/Web3Auth/web3auth-flutter-examples/issues)
- [Discord Community](https://discord.gg/web3auth)
- [Twitter/X](https://twitter.com/web3auth)

## 🔧 Platform-Specific Configuration

### Android Configuration

1. Set `compileSdkVersion 34` in your app's `build.gradle`
2. Add JitPack repository to your project-level `build.gradle`
3. Configure deep link intent filter in `AndroidManifest.xml`
4. Add Internet permission to manifest

See individual example READMEs for detailed configuration.

### iOS Configuration

1. Set minimum iOS platform to 14.0 in `Podfile`
2. Configure URL scheme in `Info.plist`
3. Allowlist `{bundleId}://auth` in the dashboard
4. Handle URL scheme in app delegate

See individual example READMEs for detailed configuration.

## 🛠️ Troubleshooting

### Common Issues

**Build errors**: Update Flutter and dependencies with `flutter upgrade` and `flutter pub upgrade`

**OAuth issues**: Verify your dashboard configuration, allowlisted URLs, and bundle IDs

**iOS deep linking**: Check URL scheme configuration in `Info.plist` and dashboard allowlist

**Android deep linking**: Verify intent filter in `AndroidManifest.xml` and package name in dashboard

**Network errors**: Ensure you're using the correct Sapphire network (devnet for localhost testing)

For more help, check the [troubleshooting docs](https://docs.metamask.io/embedded-wallets/sdk/flutter/) or ask in our [community](https://builder.metamask.io/c/embedded-wallets/5).

## 🤝 Contributing

We welcome contributions! Please feel free to submit issues and pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

---

**Built with ❤️ by the Web3Auth team**
