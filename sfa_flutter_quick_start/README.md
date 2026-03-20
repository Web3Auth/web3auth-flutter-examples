# ⚠️ DEPRECATED - Web3Auth SFA Flutter Quick Start

> **⚠️ DEPRECATION NOTICE**
> 
> This example uses the **Single Factor Auth (SFA) SDK** which is **deprecated** and no longer maintained.
> 
> **Please use the [Plug and Play (PnP) SDK](../flutter-quick-start) instead**, which provides:
> - Latest features and security updates
> - Better performance and reliability
> - Full multi-factor authentication support
> - Wallet services and advanced features
> - Active maintenance and support
>
> **Migration Path**: Use the `flutter-quick-start` example with the latest `web3auth_flutter` SDK.

---

[![Web3Auth](https://img.shields.io/badge/Web3Auth-SDK-blue)](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
[![Web3Auth](https://img.shields.io/badge/Status-Deprecated-red)](https://docs.metamask.io)

This example demonstrates how to use Web3Auth's deprecated Single Factor Authentication SDK in Flutter.

## ⚠️ Important Notice

**This SDK (`single_factor_auth_flutter`) is deprecated.**

For new projects, please use:
- **SDK**: `web3auth_flutter ^6.1.2`
- **Example**: [flutter-quick-start](../flutter-quick-start)
- **Docs**: https://docs.metamask.io/embedded-wallets/sdk/flutter/

## Why is SFA Deprecated?

The Single Factor Auth SDK has been replaced by the Plug and Play SDK, which offers:

1. **More Features**: MFA, Wallet Services, Whitelabeling, DApp Share
2. **Better UX**: Pre-built UI components and smoother flows
3. **Active Support**: Regular updates and community support
4. **Security**: Enhanced security features and best practices
5. **Future-Proof**: All new features are added to PnP SDK only

## Migration Guide

### Before (SFA - Deprecated)

```dart
import 'package:single_factor_auth_flutter/single_factor_auth_flutter.dart';

final singleFactorAuth = SingleFactorAuth(
  clientId: "YOUR_CLIENT_ID",
  network: Network.testnet,
);

await singleFactorAuth.initialize();

final privateKey = await singleFactorAuth.getKey(
  idToken: firebaseIdToken,
  verifierId: "email",
  // ...
);
```

### After (PnP - Recommended)

```dart
import 'package:web3auth_flutter/web3auth_flutter.dart';

await Web3AuthFlutter.init(
  Web3AuthOptions(
    clientId: "YOUR_CLIENT_ID",
    network: Network.sapphire_mainnet,
    redirectUrl: redirectUrl,
  )
);

await Web3AuthFlutter.initialize();

final response = await Web3AuthFlutter.login(
  LoginParams(
    loginProvider: Provider.jwt,
    extraLoginOptions: ExtraLoginOptions(
      id_token: firebaseIdToken,
      verifierIdField: 'sub',
    ),
  )
);

final privateKey = await Web3AuthFlutter.getPrivKey();
```

## Key Differences

| Feature | SFA (Deprecated) | PnP (Recommended) |
|---------|------------------|-------------------|
| SDK Package | `single_factor_auth_flutter` | `web3auth_flutter` |
| Last Update | 2023 | Active (2025+) |
| UI Components | None (headless) | Built-in modal |
| MFA Support | No | Yes |
| Wallet Services | No | Yes |
| Session Management | Manual | Automatic |
| Social Logins | Via JWT only | Direct + JWT |
| Network | Testnet/Mainnet (old) | Sapphire Devnet/Mainnet |

## Legacy Documentation

If you must maintain this example (not recommended):

### Prerequisites

- Flutter 2.18.0 or higher
- Dart 2.18.0 or higher
- Firebase or another JWT provider
- Web3Auth Dashboard account

### Installation

```bash
flutter pub add single_factor_auth_flutter
```

### Basic Usage

```dart
import 'package:single_factor_auth_flutter/single_factor_auth_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Initialize SFA
final singleFactorAuth = SingleFactorAuth(
  clientId: "YOUR_CLIENT_ID",
  network: Network.testnet,
);

await singleFactorAuth.initialize();

// Get Firebase JWT
final user = FirebaseAuth.instance.currentUser;
final idToken = await user?.getIdToken();

// Get private key
final privateKey = await singleFactorAuth.getKey(
  idToken: idToken!,
  verifierId: user!.email!,
  verifierName: "YOUR_VERIFIER_NAME",
);

print('Private key: $privateKey');
```

## Alternatives & Migration Paths

### Option 1: Migrate to PnP SDK (Recommended)

Use the [flutter-quick-start](../flutter-quick-start) or [flutter-firebase-example](../flutter-firebase-example) as a reference.

**Benefits**:
- Latest features
- Active support
- Better performance
- Future-proof

**Migration Steps**:
1. Replace `single_factor_auth_flutter` with `web3auth_flutter`
2. Update initialization code (see "After" example above)
3. Update login flow to use `Web3AuthFlutter.login()`
4. Test thoroughly with same Client ID to maintain wallet addresses

### Option 2: Use Core Kit SDK (Advanced)

For developers who need more control and don't want the pre-built UI:
- **SDK**: `@web3auth/core-kit-flutter` (coming soon)
- **Use Case**: Custom flows, wallet pregeneration, advanced features
- **Docs**: https://docs.metamask.io/embedded-wallets/core-kit/

## Support

For migration help:
- [Migration Guide](https://docs.metamask.io/embedded-wallets/migration/)
- [Builder Hub Community](https://builder.metamask.io/c/embedded-wallets/5)
- [Discord](https://discord.gg/web3auth)
- [GitHub Issues](https://github.com/Web3Auth/web3auth-flutter-examples/issues)

## Important Links

- **New Flutter SDK**: https://pub.dev/packages/web3auth_flutter
- **Documentation**: https://docs.metamask.io/embedded-wallets/sdk/flutter/
- **Dashboard**: https://dashboard.web3auth.io
- **Examples**: https://github.com/Web3Auth/web3auth-flutter-examples

---

**⚠️ This example will be removed in a future release. Please migrate to the Plug and Play SDK.**
