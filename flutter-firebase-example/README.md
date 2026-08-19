# MetaMask Embedded Wallets Flutter - Firebase Example

[![Web3Auth](https://img.shields.io/badge/MetaMask-Embedded_Wallets-blue)](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
[![Firebase](https://img.shields.io/badge/Firebase-Auth-orange?logo=firebase)](https://firebase.google.com)
[![Flutter](https://img.shields.io/badge/Flutter-SDK-02569B?logo=flutter)](https://flutter.dev)

This example demonstrates how to integrate MetaMask Embedded Wallets with Firebase Authentication in a Flutter application. It showcases a custom authentication setup using Firebase as the JWT provider with Web3Auth's blockchain functionality.

## 📝 Features

- **Firebase Authentication**: Google Sign-In, Email/Password, Phone Auth
- **Custom JWT Authentication**: Firebase ID tokens used for Web3Auth login
- **EVM Wallet**: Automatic Ethereum wallet creation linked to Firebase account
- **Blockchain Interactions**: Full blockchain operations using web3dart
- **Secure Key Management**: Non-custodial key management with Firebase identity
- **Cross-Platform**: Single codebase for iOS and Android
- **Persistent Sessions**: Firebase + Web3Auth session management

## What's new in v7

This example uses `web3auth_flutter ^7.0.0` with chains in `Web3AuthOptions`, `showWalletUI()`, `manageMFA()`, and SFA JWT sign-in via `LoginParams.idToken`. See the [root README](../README.md#whats-new-in-v7) for the full rename table.

## 🚀 Getting Started

### Prerequisites

- **Flutter**: 3.0.0 or higher
- **Dart**: 2.18.0 or higher
- **Firebase Account**: [Create one here](https://firebase.google.com)
- **MetaMask Embedded Wallets**: [Dashboard account](https://dashboard.web3auth.io)
- **iOS** (for iOS development):
  - iOS 14+, Xcode 12+, Swift 5.x, CocoaPods
- **Android** (for Android development):
  - API level 26+, compileSdkVersion 34, JDK 11+

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Web3Auth/web3auth-flutter-examples.git
   cd web3auth-flutter-examples/flutter-firebase-example
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **iOS Setup** (for iOS development):
   ```bash
   cd ios && pod install && cd ..
   ```

### Firebase Configuration

1. **Create a Firebase project**:
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project or select existing one
   - Add iOS and/or Android apps to your project

2. **Download configuration files**:
   - **iOS**: Download `GoogleService-Info.plist` and place in `ios/Runner/`
   - **Android**: Download `google-services.json` and place in `android/app/`

3. **Enable Authentication methods**:
   - In Firebase Console, go to Authentication → Sign-in method
   - Enable Google, Email/Password, or other providers you want to use

4. **Configure OAuth providers** (for Google Sign-In):
   - Follow Firebase documentation for platform-specific setup
   - Add SHA-1 fingerprint for Android
   - Configure OAuth consent screen

### Web3Auth Configuration

1. **Create a project** on the [Embedded Wallets Dashboard](https://dashboard.web3auth.io)

2. **Choose your network**:
   - **Sapphire Devnet**: For development/testing
   - **Sapphire Mainnet**: For production

3. **Create a Custom Authentication connection**:
   - Go to "Auth" → "Custom Authentication"
   - Click "Create Verifier"
   - Select "Custom" as the login provider
   - Configure Firebase:
     - **Verifier Name**: Give it a unique name (e.g., `firebase-flutter-verifier`)
     - **JWT Verifier ID**: `sub` (or `user_id` depending on your Firebase token structure)
     - **JWK Endpoint**: `https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com`
     - **Validation**: Add `iss` field with value `https://securetoken.google.com/YOUR_FIREBASE_PROJECT_ID`

4. **Configure platform settings**:
   - **iOS**: Allowlist `{bundleId}://auth`
   - **Android**: Allowlist your package name

5. **Get your Client ID and Verifier Name** from the dashboard

### Code Configuration

Update the configuration in `lib/main.dart`:

```dart
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Web3Auth
  await initWeb3Auth();
  
  runApp(MyApp());
}

Future<void> initWeb3Auth() async {
  String redirectUrl;
  
  if (Platform.isAndroid) {
    redirectUrl = 'w3a://com.example.firebaseapp/auth';
  } else if (Platform.isIOS) {
    redirectUrl = 'com.example.firebaseapp://auth';
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
├── services/
│   ├── firebase_service.dart # Firebase Auth operations
│   ├── web3auth_service.dart # Web3Auth operations
│   └── blockchain.dart       # Blockchain operations
└── screens/
    ├── home.dart             # Home screen with wallet info
    └── login.dart            # Login screen with Firebase options
```

### Core Implementation

#### 1. Initialize Firebase and Web3Auth

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first
  await Firebase.initializeApp();
  
  // Then initialize Web3Auth
  await initWeb3Auth();
  
  runApp(MyApp());
}
```

#### 2. Implement Firebase + Web3Auth Login

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> loginWithFirebase() async {
  try {
    // Step 1: Authenticate with Firebase (Google example)
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    if (googleUser == null) return; // User canceled
    
    final GoogleSignInAuthentication googleAuth = 
        await googleUser.authentication;
    
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    // Sign in to Firebase
    final UserCredential userCredential = 
        await FirebaseAuth.instance.signInWithCredential(credential);
    
    // Step 2: Get Firebase ID Token
    final User? user = userCredential.user;
    if (user == null) return;
    
    final String? idToken = await user.getIdToken();
    if (idToken == null) return;
    
    // Step 3: Login to Web3Auth with Firebase JWT (SFA)
    final Web3AuthResponse response = await Web3AuthFlutter.connectTo(
      LoginParams(
        authConnection: AuthConnection.custom,
        authConnectionId: "w3a-firebase-demo",
        idToken: idToken,
      ),
    );
    
    print('Web3Auth login successful!');
    print('User: ${response.userInfo?.email}');
    
  } catch (e) {
    print('Login error: $e');
  }
}
```

#### 3. Anonymous Firebase Login (used by this example)

```dart
Future<String> getFirebaseIdToken() async {
  final credential = await FirebaseAuth.instance.signInAnonymously();
  return await credential.user?.getIdToken(true) ?? '';
}
```

#### 4. Logout

```dart
Future<void> logout() async {
  // Logout from Web3Auth
  await Web3AuthFlutter.logout();
  
  // Logout from Firebase
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
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

- **JWT Token Security**: Firebase ID tokens are short-lived and automatically refreshed
- **Non-Custodial**: Private keys derived from Firebase identity using Shamir Secret Sharing
- **Firebase Rules**: Implement proper Firebase Security Rules for your database/storage
- **Token Validation**: Web3Auth validates Firebase JWT tokens using JWKS endpoint
- **Network Consistency**: Never change Client ID or verifier configuration in production
- **Same User Identity**: Same Firebase user always gets the same wallet address

## 🛠️ Troubleshooting

### Firebase Configuration Issues

**Problem**: Firebase initialization fails

**Solutions**:
- Verify `google-services.json` (Android) is in `android/app/`
- Verify `GoogleService-Info.plist` (iOS) is in `ios/Runner/`
- Check that Firebase project ID matches in both files
- Run `flutter clean` and rebuild

**Problem**: Google Sign-In not working on Android

**Solutions**:
- Add SHA-1 fingerprint to Firebase Console
- Enable Google Sign-In in Firebase Authentication
- Verify `google-services.json` is up to date

### Web3Auth Integration Issues

**Problem**: JWT login fails with "Invalid token" error

**Solutions**:
- Verify JWT Verifier configuration in Web3Auth dashboard
- Check that `iss` field validation matches: `https://securetoken.google.com/YOUR_PROJECT_ID`
- Ensure JWKS endpoint is correct
- Verify `userIdField` matches token structure (`sub` or `email`)
- Check that ID token is fresh (call `getIdToken()` right before Web3Auth login)

**Problem**: Different wallet address on each login

**Solutions**:
- Ensure you're using the same verifier name each time
- Verify `userIdField` is consistent
- Check that Client ID hasn't changed
- Ensure network (devnet/mainnet) is consistent

### Platform-Specific Issues

**iOS**:
- Add URL scheme to `Info.plist`
- Allowlist `{bundleId}://auth` in dashboard
- Check that Firebase GoogleService-Info.plist is included in Xcode

**Android**:
- Configure deep link intent filter in `AndroidManifest.xml`
- Add SHA-1 to Firebase for Google Sign-In
- Verify `compileSdkVersion 34`

## 📚 Resources

### Documentation
- [MetaMask Embedded Wallets Docs](https://docs.metamask.io/embedded-wallets/)
- [Flutter SDK Reference](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
- [Custom Authentication Guide](https://docs.metamask.io/embedded-wallets/sdk/flutter/advanced/custom-authentication/)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [Firebase Authentication](https://firebase.google.com/docs/auth/flutter/start)

### SDK & Packages
- [web3auth_flutter on pub.dev](https://pub.dev/packages/web3auth_flutter)
- [firebase_auth on pub.dev](https://pub.dev/packages/firebase_auth)
- [firebase_core on pub.dev](https://pub.dev/packages/firebase_core)
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
