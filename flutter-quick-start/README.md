# MetaMask Embedded Wallets Flutter Quick Start

[![Web3Auth](https://img.shields.io/badge/MetaMask-Embedded_Wallets-blue)](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
[![Flutter](https://img.shields.io/badge/Flutter-SDK-02569B?logo=flutter)](https://flutter.dev)

This example demonstrates how to integrate MetaMask Embedded Wallets (formerly Web3Auth Plug and Play) into a Flutter application. It provides a simple yet comprehensive example of implementing social authentication and blockchain functionality in a cross-platform Flutter app.

## 📝 Features

- **Social Authentication**: Google, Facebook, Twitter, Discord, Apple, and more
- **EVM Wallet**: Automatic Ethereum wallet creation and management
- **Blockchain Interactions**: Basic blockchain operations using web3dart
- **Secure Key Management**: Non-custodial key management using Shamir Secret Sharing
- **Cross-Platform**: Single codebase for iOS and Android
- **Material Design UI**: Clean, modern interface components

## 🚀 Getting Started

### Prerequisites

- **Flutter**: 3.0.0 or higher
- **Dart**: 2.18.0 or higher
- **iOS** (for iOS development):
  - iOS 14+
  - Xcode 12+
  - CocoaPods
  - Swift 5.x
- **Android** (for Android development):
  - API level 26+
  - Android Studio
  - JDK 11+
  - compileSdkVersion 34
- **MetaMask Embedded Wallets**: [Dashboard account](https://dashboard.web3auth.io)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Web3Auth/web3auth-flutter-examples.git
   cd web3auth-flutter-examples/flutter-quick-start
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
   - **Sapphire Devnet**: For development and testing (allows localhost)
   - **Sapphire Mainnet**: For production (does NOT allow localhost)

3. **Configure platform settings**:
   - **iOS**: Allowlist `{bundleId}://auth` (e.g., `com.example.w3aflutter://auth`)
   - **Android**: Allowlist your package name and configure deep link scheme

4. **Get your Client ID** from the dashboard

### Code Configuration

Update the configuration in `lib/main.dart`:

```dart
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3auth_flutter/enums.dart';
import 'dart:io';

Future<void> initWeb3Auth() async {
  late final Uri redirectUrl;
  
  if (Platform.isAndroid) {
    redirectUrl = Uri.parse('w3a://com.example.w3aflutter/auth');
  } else if (Platform.isIOS) {
    redirectUrl = Uri.parse('com.example.w3aflutter://auth');
  }

  await Web3AuthFlutter.init(
    Web3AuthOptions(
      clientId: "YOUR_WEB3AUTH_CLIENT_ID", // Get from dashboard
      network: Network.sapphire_mainnet, // or Network.sapphire_devnet
      redirectUrl: redirectUrl,
    )
  );
  
  await Web3AuthFlutter.initialize();
}
```

### Platform-Specific Configuration

#### Android

1. **Update compileSdkVersion** in `android/app/build.gradle`:
   ```groovy
   android {
       compileSdkVersion 34
       // ...
   }
   ```

2. **Add JitPack repository** in `android/settings.gradle`:
   ```groovy
   dependencyResolutionManagement {
       repositories {
           google()
           mavenCentral()
           maven { url "https://jitpack.io" }
       }
   }
   ```

3. **Configure deep link** in `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <manifest>
     <uses-permission android:name="android.permission.INTERNET" />
     
     <application>
       <activity android:name=".MainActivity">
         <intent-filter>
           <action android:name="android.intent.action.VIEW" />
           <category android:name="android.intent.category.DEFAULT" />
           <category android:name="android.intent.category.BROWSABLE" />
           <data android:scheme="w3a" android:host="com.example.w3aflutter" />
         </intent-filter>
       </activity>
     </application>
   </manifest>
   ```

4. **Handle custom tabs lifecycle** - Add to your login screen widget:
   ```dart
   class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
     @override
     void initState() {
       super.initState();
       WidgetsBinding.instance.addObserver(this);
     }
   
     @override
     void dispose() {
       super.dispose();
       WidgetsBinding.instance.removeObserver(this);
     }
   
     @override
     void didChangeAppLifecycleState(AppLifecycleState state) {
       if (state == AppLifecycleState.resumed) {
         Web3AuthFlutter.setCustomTabsClosed();
       }
     }
   }
   ```

#### iOS

1. **Set minimum iOS version** in `ios/Podfile`:
   ```ruby
   platform :ios, '14.0'
   ```

2. **Configure URL scheme** in `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.example.w3aflutter</string>
       </array>
     </dict>
   </array>
   ```

3. **Allowlist the redirect URL** in your dashboard: `com.example.w3aflutter://auth`

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
├── main.dart              # Entry point & Web3Auth initialization
├── services/
│   └── blockchain.dart    # Blockchain operations
└── screens/
    ├── home.dart          # Home screen with wallet info
    └── login.dart         # Login screen
```

### Core Implementation

#### 1. Initialize Web3Auth

```dart
import 'package:web3auth_flutter/web3auth_flutter.dart';

Future<void> initWeb3Auth() async {
  late final Uri redirectUrl;
  
  if (Platform.isAndroid) {
    redirectUrl = Uri.parse('w3a://com.example.w3aflutter/auth');
  } else if (Platform.isIOS) {
    redirectUrl = Uri.parse('com.example.w3aflutter://auth');
  }

  await Web3AuthFlutter.init(
    Web3AuthOptions(
      clientId: "YOUR_CLIENT_ID",
      network: Network.sapphire_mainnet,
      redirectUrl: redirectUrl,
    )
  );
  
  // Initialize and check for existing session
  await Web3AuthFlutter.initialize();
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
    
    // User is now logged in
    final userInfo = response.userInfo;
    print('User email: ${userInfo?.email}');
  } catch (e) {
    print('Login error: $e');
  }
}

// Logout
Future<void> logout() async {
  await Web3AuthFlutter.logout();
}

// Check existing session
Future<void> checkSession() async {
  try {
    final privateKey = await Web3AuthFlutter.getPrivKey();
    if (privateKey.isNotEmpty) {
      // User has an active session
    }
  } catch (e) {
    // No active session
  }
}
```

#### 3. Blockchain Interactions (EVM)

```dart
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

// Get private key
final privateKey = await Web3AuthFlutter.getPrivKey();

// Create credentials
final credentials = EthPrivateKey.fromHex(privateKey);

// Get wallet address
final address = credentials.address;

// Create Web3Client
final client = Web3Client(
  'https://rpc.ankr.com/eth', // Your RPC URL
  Client(),
);

// Get balance
final balance = await client.getBalance(address);
final ethBalance = balance.getValueInUnit(EtherUnit.ether);

// Send transaction
final txHash = await client.sendTransaction(
  credentials,
  Transaction(
    to: EthereumAddress.fromHex('0x...'),
    value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0.01),
  ),
  chainId: 1, // Ethereum mainnet
);
```

## 🔒 Security Considerations

- **Non-Custodial**: Private keys are managed using Shamir Secret Sharing - no single party (including MetaMask/Web3Auth) holds the full key
- **Deterministic Wallets**: Same user + same config = same wallet address
- **Network Consistency**: Never change Client ID or Sapphire network in production
- **Secure Storage**: Session data is securely stored on device
- **OAuth Best Practices**: Social login credentials handled through standard OAuth flows

## 🛠️ Troubleshooting

### Common Issues

#### Build Errors

**Problem**: Compilation fails or dependencies conflict

**Solution**:
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..  # For iOS
flutter run
```

#### OAuth/Login Issues

**Problem**: Login flow doesn't start or fails

**Solutions**:
- Verify Client ID is correct in code
- Check that redirect URLs are allowlisted in dashboard
- Ensure network setting matches your dashboard project (devnet vs mainnet)
- For Android: Verify deep link intent filter in `AndroidManifest.xml`
- For iOS: Check URL scheme in `Info.plist`

#### Deep Link Not Working

**Android**:
- Verify scheme and host in `AndroidManifest.xml` match your code
- Check package name is allowlisted in dashboard
- Ensure `INTERNET` permission is added

**iOS**:
- Verify URL scheme in `Info.plist` matches bundle ID
- Check that `{bundleId}://auth` is allowlisted in dashboard
- Ensure app handles URL scheme correctly

#### Session Management

**Problem**: User session not persisting or being restored

**Solution**:
```dart
// Always call initialize() after init()
await Web3AuthFlutter.init(...);
await Web3AuthFlutter.initialize(); // This checks for existing session

// Check for active session
try {
  final privateKey = await Web3AuthFlutter.getPrivKey();
  if (privateKey.isNotEmpty) {
    // Session exists
  }
} catch (e) {
  // No active session
}
```

## 📚 Resources

### Documentation
- [MetaMask Embedded Wallets Docs](https://docs.metamask.io/embedded-wallets/)
- [Flutter SDK Reference](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
- [Dashboard Setup Guide](https://docs.metamask.io/embedded-wallets/dashboard/)
- [Login Methods](https://docs.metamask.io/embedded-wallets/sdk/flutter/usage/login/)

### SDK & Package
- [pub.dev Package](https://pub.dev/packages/web3auth_flutter)
- [GitHub Repository](https://github.com/Web3Auth/web3auth-flutter-sdk)
- [Release Notes](https://github.com/Web3Auth/web3auth-flutter-sdk/releases)
- [Example Code](https://github.com/Web3Auth/web3auth-flutter-examples)

### Community & Support
- [MetaMask Builder Hub](https://builder.metamask.io/c/embedded-wallets/5)
- [Discord Community](https://discord.gg/web3auth)
- [GitHub Issues](https://github.com/Web3Auth/web3auth-flutter-examples/issues)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/web3auth)

## 🤝 Support

Need help? Reach out through:
- [Builder Hub Community](https://builder.metamask.io/c/embedded-wallets/5)
- [GitHub Issues](https://github.com/Web3Auth/web3auth-flutter-examples/issues)
- [Discord](https://discord.gg/web3auth)

## 📄 License

This example is available under the MIT License. See the [LICENSE](../../LICENSE) file for more info.
