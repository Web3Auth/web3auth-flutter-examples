# ⚠️ DEPRECATED - Web3Auth SFA Flutter Solana Example

> **⚠️ DEPRECATION NOTICE**
> 
> This example uses the **Single Factor Auth (SFA) SDK** which is **deprecated** and no longer maintained.
> 
> **Please use the [flutter-solana-example](../flutter-solana-example) instead**, which uses the latest Plug and Play SDK with full Solana support.
>
> **Migration Path**: Use the `flutter-solana-example` with the latest `web3auth_flutter` SDK for Solana integration.

---

[![Web3Auth](https://img.shields.io/badge/Web3Auth-SDK-blue)](https://docs.metamask.io/embedded-wallets/sdk/flutter/)
[![Web3Auth](https://img.shields.io/badge/Status-Deprecated-red)](https://docs.metamask.io)
[![Solana](https://img.shields.io/badge/Solana-Blockchain-9945FF?logo=solana)](https://solana.com)

This example demonstrates how to use Web3Auth's deprecated Single Factor Authentication SDK with Solana in Flutter.

## ⚠️ Important Notice

**This SDK (`single_factor_auth_flutter`) is deprecated.**

For Solana projects, please use:
- **SDK**: `web3auth_flutter ^6.1.2`
- **Example**: [flutter-solana-example](../flutter-solana-example)
- **Docs**: https://docs.metamask.io/embedded-wallets/sdk/flutter/

## Why Migrate?

The new Plug and Play SDK offers:

1. **Better Solana Support**: Direct Ed25519 key access via `getED25519PrivKey()`
2. **More Features**: MFA, Wallet Services, Social logins without JWT
3. **Active Support**: Regular updates and bug fixes
4. **Better UX**: Pre-built authentication UI
5. **Future-Proof**: All new features added to PnP SDK only

## Quick Migration Guide

### Before (SFA - Deprecated)

```dart
import 'package:single_factor_auth_flutter/single_factor_auth_flutter.dart';

final singleFactorAuth = SingleFactorAuth(
  clientId: "YOUR_CLIENT_ID",
  network: Network.testnet,
);

await singleFactorAuth.initialize();

final privateKey = await singleFactorAuth.getKey(
  idToken: jwtToken,
  verifierId: userId,
  // ...
);

// Use privateKey with Solana
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

// Direct social login (no JWT needed!)
final response = await Web3AuthFlutter.login(
  LoginParams(loginProvider: Provider.google)
);

// Get Solana Ed25519 key
final solanaPrivateKey = await Web3AuthFlutter.getED25519PrivKey();

// Use with Solana
```

## See the New Example

Check out the [flutter-solana-example](../flutter-solana-example) for:
- Complete Solana integration
- SOL transfers and balance checks
- SPL token support
- NFT management
- Devnet & Mainnet support
- Better error handling

## Support

For migration help:
- [Migration Guide](https://docs.metamask.io/embedded-wallets/migration/)
- [Solana Integration Docs](https://docs.metamask.io/embedded-wallets/sdk/flutter/blockchain/solana/)
- [Builder Hub Community](https://builder.metamask.io/c/embedded-wallets/5)
- [Discord](https://discord.gg/web3auth)

---

**⚠️ This example will be removed in a future release. Please migrate to the Plug and Play SDK.**
