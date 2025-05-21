import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_playground/core/service_locator.dart';
import 'package:flutter_playground/core/utils/strings.dart';
import 'package:flutter_playground/core/utils/web3auth_utils.dart';
import 'package:flutter_playground/features/home/domain/repositories/chain_config_repostiory.dart';
import 'package:flutter_playground/features/home/presentation/provider/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

import 'features/home/presentation/screens/home_screen.dart';
import 'features/login/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up ServiceLoactor used for dependency injection.
  ServiceLocator.setUp();

  // Initialize the Web3AuthFlutter instance.
  await Web3AuthFlutter.init(
    Web3AuthOptions(
      clientId: StringConstants.web3AuthClientId,
      network: Network.sapphire_mainnet,
      redirectUrl: resolveRedirectUrl(),
      whiteLabel: WhiteLabelData(
        appName: StringConstants.appName,
        mode: ThemeModes.dark,
      ),
    ),
  );

  try {
    await Web3AuthFlutter.initialize();
  } catch (e) {
    log(e.toString());
  }

  final chainConfigRepository = ServiceLocator.getIt<ChainConfigRepository>();
  final chainConfigs = chainConfigRepository.prepareChains();

  // Setup HomeProvider for state management.
  runApp(ChangeNotifierProvider(
    create: (_) => HomeProvider(chainConfigs),
    builder: (_, __) {
      return const MainApp();
    },
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final Future<String> privateKeyFuture;
  @override
  void initState() {
    super.initState();
    privateKeyFuture = Web3AuthFlutter.getPrivKey();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<String>(
        future: privateKeyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              // If snapshot.data is empty, it means there's no private key,
              // and no active user session.
              if (snapshot.data!.isNotEmpty) {
                return const HomeScreen();
              }
            }
            return const LoginScreen();
          }
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      ),
    );
  }
}
