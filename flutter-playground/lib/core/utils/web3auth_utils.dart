import 'dart:io';

import 'package:flutter_playground/core/utils/chain_configs.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';

String resolveRedirectUrl() {
  if (Platform.isAndroid) {
    return 'w3a://com.example.flutterplayground';
  } else {
    return 'com.w3a.flutterplayground://auth';
  }
}

List<Chains> buildWeb3AuthChains() {
  return chainConfigs.map((config) {
    return Chains(
      chainNamespace: ChainNamespace.values.firstWhere(
        (namespace) => namespace.name == config['chainNamespace'],
        orElse: () => ChainNamespace.eip155,
      ),
      chainId: config['chainId']!,
      rpcTarget: config['rpcTarget']!,
      displayName: config['displayName'],
      ticker: config['ticker'],
      blockExplorerUrl: config['blockExplorerUrl'],
      logo: config['logo'],
    );
  }).toList();
}
