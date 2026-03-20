# MetaMask Embedded Wallets Flutter - Grouped Connections Example

[![Web3Auth](https://img.shields.io/badge/MetaMask-Embedded_Wallets-blue)](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
[![Flutter](https://img.shields.io/badge/Flutter-SDK-02569B?logo=flutter)](https://flutter.dev)

This example demonstrates how to use **Grouped Connections** (formerly Aggregate Verifiers) in a Flutter application. Grouped Connections allow users to log in through different authentication methods while maintaining the **same wallet address**, providing a seamless multi-provider authentication experience.

## 📝 Features

- **Multi-Provider Authentication**: Google, Auth0, Email Passwordless, and more
- **Single Wallet Address**: Same wallet regardless of login method used
- **Flexible Identity**: Users can choose their preferred login method
- **EVM Wallet**: Automatic Ethereum wallet creation linked across providers
- **Blockchain Interactions**: Full blockchain operations using web3dart
- **Secure Key Management**: Non-custodial key management with consistent identity
- **Cross-Platform**: Single codebase for iOS and Android

## 🔑 What are Grouped Connections?

Grouped Connections link multiple authentication methods together so users get the **same wallet address** regardless of how they log in:

- User logs in with **Google** → Gets wallet `0xABC...`
- Same user logs in with **Email Passwordless** → Gets **same** wallet `0xABC...`
- Without grouping, each method would create a **different** wallet!

**Use Case**: Your users want flexibility - some prefer Google, others prefer email. With Grouped Connections, they get one wallet they can access via any method.

## 🚀 Getting Started

### Prerequisites

- **Flutter**: 3.0.0 or higher
- **Dart**: 2.18.0 or higher
- **MetaMask Embedded Wallets**: [Dashboard account](https://dashboard.web3auth.io)
- **Auth0 Account** (optional, for custom provider): [Create one here](https://auth0.com)
- **iOS** (for iOS development):
  - iOS 14+, Xcode 12+, Swift 5.x, CocoaPods
- **Android** (for Android development):
  - API level 26+, compileSdkVersion 34, JDK 11+

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Web3Auth/web3auth-flutter-examples.git
   cd web3auth-flutter-examples/flutter-aggregate-verifier-example
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

#### Step 1: Create a Grouped Connection

1. **Create a project** on the [Embedded Wallets Dashboard](https://dashboard.web3auth.io)

2. **Choose your network**:
   - **Sapphire Devnet**: For development/testing
   - **Sapphire Mainnet**: For production

3. **Create a Grouped Connection**:
   - Go to "Auth" → "Grouped Connections"
   - Click "Create Grouped Connection"
   - Give it a name (e.g., `flutter-grouped-auth`)

#### Step 2: Add Sub-Connections

Add the authentication methods you want to group together:

**Example 1: Google + Email Passwordless**

1. **Add Google sub-connection**:
   - Provider: Google
   - User ID Field: `email`
   - This uses the user's email as the common identifier

2. **Add Email Passwordless sub-connection**:
   - Provider: Email Passwordless
   - User ID Field: `email`
   - Same email = same wallet!

**Example 2: Custom Auth0 + Google**

1. **Add Auth0 sub-connection**:
   - Provider: Custom (Auth0)
   - Configure Auth0 domain and client ID
   - User ID Field: `email`

2. **Add Google sub-connection**:
   - Provider: Google
   - User ID Field: `email`

**Critical**: The **User ID Field** must be the same across all sub-connections and must contain the same value for the same user. For example, `email` works for Google + Email Passwordless because both use the user's email address.

#### Step 3: Configure Platform Settings

- **iOS**: Allowlist `{bundleId}://auth`
- **Android**: Allowlist your package name

### Code Configuration

Update the configuration in `lib/main.dart`:

```dart
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'dart:io';

Future<void> initWeb3Auth() async {
  late final Uri redirectUrl;
  
  if (Platform.isAndroid) {
    redirectUrl = Uri.parse('w3a://com.example.aggregateapp/auth');
  } else if (Platform.isIOS) {
    redirectUrl = Uri.parse('com.example.aggregateapp://auth');
  }

  await Web3AuthFlutter.init(
    Web3AuthOptions(
      clientId: "YOUR_WEB3AUTH_CLIENT_ID",
      network: Network.sapphire_mainnet,
      redirectUrl: redirectUrl,
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

## 💡 Implementation Details

### Project Structure

```
lib/
├── main.dart                 # Entry point & initialization
├── services/
│   ├── web3auth_service.dart # Web3Auth operations
│   └── blockchain.dart       # Blockchain operations
└── screens/
    ├── home.dart             # Home screen with wallet info
    └── login.dart            # Login screen with multiple options
```

### Core Implementation

#### 1. Login with Google (Grouped Connection)

```dart
Future<void> loginWithGoogle() async {
  try {
    final Web3AuthResponse response = await Web3AuthFlutter.login(
      LoginParams(
        loginProvider: Provider.google,
        mfaLevel: MFALevel.NONE,
      )
    );
    
    print('Logged in with Google');
    print('Wallet address: ${response.userInfo?.publicAddress}');
  } catch (e) {
    print('Login error: $e');
  }
}
```

#### 2. Login with Email Passwordless (Same Grouped Connection)

```dart
Future<void> loginWithEmailPasswordless(String email) async {
  try {
    final Web3AuthResponse response = await Web3AuthFlutter.login(
      LoginParams(
        loginProvider: Provider.email_passwordless,
        extraLoginOptions: ExtraLoginOptions(
          login_hint: email, // User's email address
        ),
      )
    );
    
    print('Logged in with Email Passwordless');
    print('Wallet address: ${response.userInfo?.publicAddress}');
    // This will be the SAME address as Google login if using same email!
  } catch (e) {
    print('Login error: $e');
  }
}
```

#### 3. Login with Custom Auth (e.g., Auth0)

```dart
import 'package:auth0_flutter/auth0_flutter.dart';

Future<void> loginWithAuth0() async {
  try {
    // Step 1: Login with Auth0
    final auth0 = Auth0('YOUR_AUTH0_DOMAIN', 'YOUR_AUTH0_CLIENT_ID');
    final credentials = await auth0.webAuthentication().login();
    
    // Step 2: Get ID Token
    final idToken = credentials.idToken;
    
    // Step 3: Login to Web3Auth with JWT
    final Web3AuthResponse response = await Web3AuthFlutter.login(
      LoginParams(
        loginProvider: Provider.jwt,
        extraLoginOptions: ExtraLoginOptions(
          id_token: idToken,
          verifierIdField: 'email', // Must match grouped connection config
        ),
      )
    );
    
    print('Logged in with Auth0');
    print('Wallet address: ${response.userInfo?.publicAddress}');
    // Same address as Google/Email if using same email!
  } catch (e) {
    print('Login error: $e');
  }
}
```

#### 4. Get Wallet Information

```dart
import 'package:web3dart/web3dart.dart';

Future<void> getWalletInfo() async {
  // Get private key from Web3Auth
  final privateKey = await Web3AuthFlutter.getPrivKey();
  
  // Create credentials
  final credentials = EthPrivateKey.fromHex(privateKey);
  
  // Get address
  final address = credentials.address;
  print('Wallet address: ${address.hex}');
  
  // This address will be the same regardless of login method!
  
  // Get balance
  final client = Web3Client('YOUR_RPC_URL', Client());
  final balance = await client.getBalance(address);
  print('Balance: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
}
```

#### 5. Logout

```dart
Future<void> logout() async {
  await Web3AuthFlutter.logout();
}
```

## 🔒 Security Considerations

- **Consistent Identity**: User ID field must be the same across all providers
- **Email Verification**: For email-based grouping, ensure emails are verified
- **Non-Custodial**: Private keys derived using Shamir Secret Sharing
- **Network Consistency**: Never change Client ID or grouped connection config in production
- **User ID Field Selection**: Choose a field that uniquely identifies users across all providers
- **Provider Compatibility**: Ensure all grouped providers return the same user identifier

## ⚠️ Important Considerations

### User ID Field Requirements

The **User ID Field** must:
1. Exist in the JWT/OAuth response from **all** sub-connections
2. Contain the **same value** for the same user across providers
3. Be **unique** per user

**Good combinations**:
- Google (`email`) + Email Passwordless (`email`)
- Auth0 Google (`email`) + Auth0 Facebook (`email`)
- Two custom JWT providers with same email field

**Bad combinations**:
- Google (`sub`) + Email Passwordless (`email`) - Different field values!
- Twitter (`user_id`) + Google (`sub`) - Different identifiers!

### Testing Grouped Connections

1. **Test with same user**:
   ```
   Login with Google (user@example.com) → Note wallet address
   Logout
   Login with Email Passwordless (user@example.com) → Verify SAME address
   ```

2. **Test with different users**:
   ```
   Login with Google (user1@example.com) → Note wallet address
   Logout
   Login with Email Passwordless (user2@example.com) → Verify DIFFERENT address
   ```

## 🛠️ Troubleshooting

### Different Wallet Addresses Issue

**Problem**: Same user gets different wallet addresses with different login methods

**Solutions**:
- Verify Grouped Connection is properly configured in dashboard
- Check that User ID Field is **identical** across all sub-connections
- Ensure the field value (e.g., email) is actually the same for the user
- Verify you're using the same Client ID
- Check network (devnet/mainnet) hasn't changed

### Login Method Not Working

**Problem**: One of the login methods fails

**Solutions**:
- Test each sub-connection independently first
- Verify the sub-connection configuration in dashboard
- For JWT/custom auth: Ensure JWT contains the User ID Field
- Check that all OAuth providers are properly configured

### User ID Field Not Found

**Problem**: Error about missing verifier ID field

**Solutions**:
- Check the JWT token to see what fields are actually present
- Verify the User ID Field name matches exactly (case-sensitive)
- For Google: Use `email` or `sub`
- For Auth0: Use `sub` or `email` depending on configuration

## 📚 Resources

### Documentation
- [MetaMask Embedded Wallets Docs](https://docs.metamask.io/embedded-wallets/)
- [Flutter SDK Reference](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
- [Grouped Connections Guide](https://docs.metamask.io/embedded-wallets/dashboard/grouped-connections/)
- [Custom Authentication](https://docs.metamask.io/embedded-wallets/sdk/flutter/advanced/custom-authentication/)

### SDK & Packages
- [web3auth_flutter on pub.dev](https://pub.dev/packages/web3auth_flutter)
- [GitHub Repository](https://github.com/Web3Auth/web3auth-flutter-sdk)

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
