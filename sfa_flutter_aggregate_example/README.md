# ⚠️ DEPRECATED - Web3Auth SFA Flutter Aggregate Example

> **⚠️ DEPRECATION NOTICE**
> 
> This example uses the **Single Factor Auth (SFA) SDK** which is **deprecated** and no longer maintained.
> 
> **Please use the [flutter-aggregate-verifier-example](../flutter-aggregate-verifier-example) instead**, which uses Grouped Connections with the latest Plug and Play SDK.
>
> **Migration Path**: Use the `flutter-aggregate-verifier-example` with the latest `web3auth_flutter` SDK for multi-provider authentication.

---

[![Web3Auth](https://img.shields.io/badge/Web3Auth-SDK-blue)](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
[![Web3Auth](https://img.shields.io/badge/Status-Deprecated-red)](https://docs.metamask.io)

This example demonstrates how to use Web3Auth's deprecated Single Factor Authentication SDK with aggregate verifiers in Flutter.

## ⚠️ Important Notice

**This SDK (`single_factor_auth_flutter`) is deprecated.**

For multi-provider authentication, please use:
- **SDK**: `web3auth_flutter ^6.1.2`
- **Example**: [flutter-aggregate-verifier-example](../flutter-aggregate-verifier-example)
- **Feature**: Grouped Connections (formerly Aggregate Verifiers)
- **Docs**: https://docs.metamask.io/embedded-wallets/dashboard/grouped-connections/

## Why Migrate?

The new Plug and Play SDK with Grouped Connections offers:

1. **Easier Setup**: Configure once in dashboard, use everywhere
2. **Better UX**: Seamless switching between login methods
3. **More Providers**: Google, Email, Auth0, and more out of the box
4. **No Manual JWT**: Social logins work directly
5. **Active Support**: Regular updates and community help

## Terminology Change

- **Old**: Aggregate Verifiers
- **New**: Grouped Connections

Same concept, better implementation!

## Quick Migration Guide

### Before (SFA with Aggregate Verifier - Deprecated)

```dart
import 'package:single_factor_auth_flutter/single_factor_auth_flutter.dart';

final singleFactorAuth = SingleFactorAuth(
  clientId: "YOUR_CLIENT_ID",
  network: Network.testnet,
);

await singleFactorAuth.initialize();

// Complex manual JWT handling for each provider
final privateKey = await singleFactorAuth.getKey(
  idToken: jwtToken,
  verifierId: userId,
  verifierName: "aggregate-verifier-name",
  // ... more complex config
);
```

### After (PnP with Grouped Connections - Recommended)

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

// Easy! Login with Google
await Web3AuthFlutter.login(
  LoginParams(loginProvider: Provider.google)
);

// Or Email Passwordless - SAME WALLET!
await Web3AuthFlutter.login(
  LoginParams(
    loginProvider: Provider.email_passwordless,
    extraLoginOptions: ExtraLoginOptions(
      login_hint: userEmail,
    ),
  )
);

final privateKey = await Web3AuthFlutter.getPrivKey();
// Same private key regardless of login method! 🎉
```

## Key Benefits of New Approach

| Feature | Old (SFA) | New (PnP) |
|---------|-----------|-----------|
| Setup | Manual JWT for each provider | Configure once in dashboard |
| Social Logins | Requires JWT tokens | Direct integration |
| Wallet Consistency | Manual configuration | Automatic with Grouped Connections |
| User Experience | Multiple steps | Single click |
| Maintenance | High complexity | Low complexity |

## See the New Example

Check out [flutter-aggregate-verifier-example](../flutter-aggregate-verifier-example) for:
- Complete Grouped Connections setup
- Google + Email Passwordless example
- Auth0 + Custom JWT integration
- Same wallet across all methods
- Best practices and troubleshooting

## Dashboard Configuration

The new approach uses dashboard configuration:

1. Go to [Web3Auth Dashboard](https://dashboard.web3auth.io)
2. Navigate to Auth → Grouped Connections
3. Create a grouped connection
4. Add sub-connections (Google, Email, etc.)
5. Ensure User ID Field is the same across all (e.g., `email`)
6. Save and use in your app!

No complex code changes needed - just call `login()` with different providers!

## Support

For migration help:
- [Grouped Connections Guide](https://docs.metamask.io/embedded-wallets/dashboard/grouped-connections/)
- [Migration Guide](https://docs.metamask.io/embedded-wallets/migration/)
- [Builder Hub Community](https://builder.metamask.io/c/embedded-wallets/5)
- [Discord](https://discord.gg/web3auth)

---

**⚠️ This example will be removed in a future release. Please migrate to the Plug and Play SDK.**
