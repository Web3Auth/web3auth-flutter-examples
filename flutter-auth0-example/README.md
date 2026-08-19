# MetaMask Embedded Wallets Flutter - Auth0 Example

[![Web3Auth](https://img.shields.io/badge/MetaMask-Embedded_Wallets-blue)](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
[![Auth0](https://img.shields.io/badge/Auth0-Custom_Auth-EB5424?logo=auth0)](https://auth0.com)
[![Flutter](https://img.shields.io/badge/Flutter-SDK-02569B?logo=flutter)](https://flutter.dev)

This example demonstrates how to integrate MetaMask Embedded Wallets with Auth0 authentication in a Flutter application. It showcases a custom authentication setup using Auth0 as the identity provider with Web3Auth's blockchain functionality.

## 📝 Features

- **Auth0 Social Logins**: Google, Facebook, Twitter, GitHub, and more
- **Universal Login**: Auth0's hosted login page with customization options
- **Custom JWT Authentication**: Auth0 ID tokens used for Web3Auth login
- **EVM Wallet**: Automatic Ethereum wallet creation linked to Auth0 identity
- **Blockchain Interactions**: Full blockchain operations using web3dart
- **Secure Key Management**: Non-custodial key management with Auth0 identity
- **Cross-Platform**: Single codebase for iOS and Android
- **Enterprise-Ready**: Auth0's enterprise features (SSO, MFA, etc.)

## What's new in v7

This example uses `web3auth_flutter ^7.0.0` with `authConnectionConfig` and `AuthConnection.custom` for Auth0 JWT login. See the [root README](../README.md#whats-new-in-v7) for the full rename table.

## 🚀 Getting Started

### Prerequisites

- **Flutter**: 3.0.0 or higher
- **Dart**: 2.18.0 or higher
- **Auth0 Account**: [Create one here](https://auth0.com)
- **MetaMask Embedded Wallets**: [Dashboard account](https://dashboard.web3auth.io)
- **iOS** (for iOS development):
  - iOS 14+, Xcode 12+, Swift 5.x, CocoaPods
- **Android** (for Android development):
  - API level 26+, compileSdkVersion 34, JDK 11+

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Web3Auth/web3auth-flutter-examples.git
   cd web3auth-flutter-examples/flutter-auth0-example
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **iOS Setup** (for iOS development):
   ```bash
   cd ios && pod install && cd ..
   ```

### Auth0 Configuration

1. **Create an Auth0 Application**:
   - Go to [Auth0 Dashboard](https://manage.auth0.com)
   - Create a new application → Native
   - Note your **Domain** and **Client ID**

2. **Configure Allowed Callback URLs**:
   - Add for iOS: `com.example.auth0app://YOUR_AUTH0_DOMAIN/ios/com.example.auth0app/callback`
   - Add for Android: `com.example.auth0app://YOUR_AUTH0_DOMAIN/android/com.example.auth0app/callback`

3. **Configure Allowed Logout URLs**:
   - Add for iOS: `com.example.auth0app://YOUR_AUTH0_DOMAIN/ios/com.example.auth0app/logout`
   - Add for Android: `com.example.auth0app://YOUR_AUTH0_DOMAIN/android/com.example.auth0app/logout`

4. **Enable social connections** (optional):
   - Go to Authentication → Social
   - Enable and configure providers (Google, Facebook, etc.)

### Web3Auth Configuration

1. **Create a project** on the [Embedded Wallets Dashboard](https://dashboard.web3auth.io)

2. **Choose your network**:
   - **Sapphire Devnet**: For development/testing
   - **Sapphire Mainnet**: For production

3. **Create a Custom Authentication connection**:
   - Go to "Auth" → "Custom Authentication"
   - Click "Create Verifier"
   - Configure Auth0:
     - **Verifier Name**: Give it a unique name (e.g., `auth0-flutter-verifier`)
     - **Login Provider**: Select "Auth0"
     - **Auth0 Domain**: Your Auth0 domain (e.g., `your-tenant.us.auth0.com`)
     - **Auth0 Client ID**: Your Auth0 application client ID
     - **JWT Verifier ID**: `sub` (Auth0 user ID)
     - **JWK Endpoint**: Auto-filled as `https://YOUR_DOMAIN/.well-known/jwks.json`

4. **Configure platform settings**:
   - **iOS**: Allowlist `{bundleId}://auth`
   - **Android**: Allowlist your package name

5. **Get your Client ID and Verifier Name** from the dashboard

### Code Configuration

Update the configuration in `lib/config/auth0_config.dart`:

```dart
class Auth0Config {
  static const String domain = "your-tenant.us.auth0.com";
  static const String clientId = "YOUR_AUTH0_CLIENT_ID";
  
  // Redirect URLs
  static String getCallbackUrl(String bundleId) {
    if (Platform.isAndroid) {
      return "$bundleId://$domain/android/$bundleId/callback";
    } else if (Platform.isIOS) {
      return "$bundleId://$domain/ios/$bundleId/callback";
    }
    throw UnsupportedError('Unsupported platform');
  }
}
```

Update Web3Auth configuration in `lib/main.dart`:

```dart
import 'package:web3auth_flutter/web3auth_flutter.dart';

Future<void> initWeb3Auth() async {
  String redirectUrl;
  
  if (Platform.isAndroid) {
    redirectUrl = 'w3a://com.example.auth0app/auth';
  } else if (Platform.isIOS) {
    redirectUrl = 'com.example.auth0app://auth';
  }

  await Web3AuthFlutter.init(
    Web3AuthOptions(
      clientId: "YOUR_WEB3AUTH_CLIENT_ID",
      web3AuthNetwork: Web3AuthNetwork.sapphire_mainnet,
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
├── main.dart                # Entry point & initialization
├── config/
│   └── auth0_config.dart    # Auth0 configuration
├── services/
│   ├── auth0_service.dart   # Auth0 authentication
│   ├── web3auth_service.dart # Web3Auth operations
│   └── blockchain.dart      # Blockchain operations
└── screens/
    ├── home.dart            # Home screen with wallet info
    └── login.dart           # Login screen
```

### Core Implementation

#### 1. Initialize Auth0 and Web3Auth

```dart
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

// Initialize Auth0
final auth0 = Auth0(
  Auth0Config.domain,
  Auth0Config.clientId,
);

// Initialize Web3Auth
Future<void> initWeb3Auth() async {
  // ... (see Code Configuration section above)
}
```

#### 2. Implement Auth0 + Web3Auth Login

```dart
import 'package:auth0_flutter/auth0_flutter.dart';

Future<void> loginWithAuth0() async {
  try {
    // Step 1: Login with Auth0
    final credentials = await auth0.webAuthentication().login(
      useEphemeralSession: true, // Don't persist session in browser
    );
    
    // Step 2: Get ID Token
    final idToken = credentials.idToken;
    
    // Step 3: Login to Web3Auth with Auth0 JWT
    final Web3AuthResponse response = await Web3AuthFlutter.connectTo(
      LoginParams(
        authConnection: AuthConnection.custom,
        extraLoginOptions: ExtraLoginOptions(
          id_token: idToken,
          userIdField: 'sub',
          domain: Auth0Config.domain,
        ),
      )
    );
    
    print('Web3Auth login successful!');
    print('User: ${response.userInfo?.email}');
    
  } on WebAuthenticationException catch (e) {
    print('Auth0 error: ${e.message}');
  } catch (e) {
    print('Login error: $e');
  }
}
```

#### 3. Specify Social Connection (Optional)

```dart
Future<void> loginWithGoogle() async {
  try {
    // Login with specific social connection
    final credentials = await auth0.webAuthentication().login(
      parameters: {
        'connection': 'google-oauth2', // Or 'facebook', 'github', etc.
      },
    );
    
    final idToken = credentials.idToken;
    
    await Web3AuthFlutter.connectTo(
      LoginParams(
        authConnection: AuthConnection.custom,
        extraLoginOptions: ExtraLoginOptions(
          id_token: idToken,
          userIdField: 'sub',
        ),
      )
    );
  } catch (e) {
    print('Login error: $e');
  }
}
```

#### 4. Logout

```dart
Future<void> logout() async {
  // Logout from Web3Auth
  await Web3AuthFlutter.logout();
  
  // Logout from Auth0
  await auth0.webAuthentication().logout();
}
```

#### 5. Get Blockchain Credentials

```dart
import 'package:web3dart/web3dart.dart';

Future<void> getWalletInfo() async {
  // Get private key from Web3Auth
  final privateKey = await Web3AuthFlutter.getPrivateKey();
  
  // Create credentials
  final credentials = EthPrivateKey.fromHex(privateKey);
  
  // Get address
  final address = credentials.address;
  print('Wallet address: ${address.hex}');
  
  // Get balance
  final client = Web3Client('YOUR_RPC_URL', Client());
  final balance = await client.getBalance(address);
  print('Balance: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
}
```

## 🔒 Security Considerations

- **JWT Token Security**: Auth0 ID tokens are short-lived and securely validated
- **Non-Custodial**: Private keys derived from Auth0 identity using Shamir Secret Sharing
- **OAuth 2.0 / OIDC**: Industry-standard authentication protocols
- **Token Validation**: Web3Auth validates Auth0 JWT tokens using JWKS endpoint
- **Network Consistency**: Never change Client ID or verifier configuration in production
- **Same User Identity**: Same Auth0 user always gets the same wallet address
- **Enterprise Security**: Auth0 provides MFA, anomaly detection, breached password detection

## 🛠️ Troubleshooting

### Auth0 Configuration Issues

**Problem**: Auth0 login fails or doesn't redirect back

**Solutions**:
- Verify callback URLs are correctly configured in Auth0 dashboard
- Check that URL schemes match in both Auth0 and your app
- For iOS: Verify URL scheme in `Info.plist`
- For Android: Verify intent filter in `AndroidManifest.xml`

**Problem**: "Invalid state" error

**Solutions**:
- This usually means callback URL mismatch
- Verify the redirect URL format exactly matches Auth0 configuration
- Check for typos in domain or bundle ID

### Web3Auth Integration Issues

**Problem**: JWT login fails with "Invalid token" error

**Solutions**:
- Verify Custom Verifier configuration in Web3Auth dashboard
- Check that Auth0 domain and client ID match exactly
- Ensure JWKS endpoint is accessible
- Verify `userIdField` is set to `sub`
- Check that ID token is valid and not expired

**Problem**: Different wallet address on each login

**Solutions**:
- Ensure you're using the same verifier name each time
- Verify `userIdField` is consistent (`sub`)
- Check that Client ID hasn't changed
- Ensure network (devnet/mainnet) is consistent

### Platform-Specific Issues

**iOS**:
- Add URL schemes to `Info.plist` for both Auth0 and Web3Auth
- Allowlist `{bundleId}://auth` in Web3Auth dashboard
- Configure Auth0 callback: `{bundleId}://YOUR_DOMAIN/ios/{bundleId}/callback`

**Android**:
- Configure intent filters in `AndroidManifest.xml` for both Auth0 and Web3Auth
- Verify `compileSdkVersion 34`
- Check package name allowlist in Web3Auth dashboard

## 📚 Resources

### Documentation
- [MetaMask Embedded Wallets Docs](https://docs.metamask.io/embedded-wallets/)
- [Flutter SDK Reference](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
- [Custom Authentication Guide](https://docs.metamask.io/embedded-wallets/sdk/flutter/advanced/custom-authentication/)
- [Auth0 Flutter SDK](https://auth0.com/docs/quickstart/native/flutter)
- [Auth0 Documentation](https://auth0.com/docs)

### SDK & Packages
- [web3auth_flutter on pub.dev](https://pub.dev/packages/web3auth_flutter)
- [auth0_flutter on pub.dev](https://pub.dev/packages/auth0_flutter)
- [GitHub Repository](https://github.com/Web3Auth/web3auth-flutter-sdk)

### Community & Support
- [MetaMask Builder Hub](https://builder.metamask.io/c/embedded-wallets/5)
- [Auth0 Community](https://community.auth0.com)
- [Discord Community](https://discord.gg/web3auth)
- [GitHub Issues](https://github.com/Web3Auth/web3auth-flutter-examples/issues)

## 🤝 Support

Need help? Reach out through:
- [Builder Hub Community](https://builder.metamask.io/c/embedded-wallets/5)
- [GitHub Issues](https://github.com/Web3Auth/web3auth-flutter-examples/issues)
- [Discord](https://discord.gg/web3auth)

## 📄 License

This example is available under the MIT License. See the [LICENSE](../../LICENSE) file for more info.
