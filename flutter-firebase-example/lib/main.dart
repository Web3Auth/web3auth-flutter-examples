import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'dart:async';

import 'package:web3auth_flutter/web3auth_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String _result = '';
  bool logoutVisible = false;
  String rpcUrl = 'https://eth.llamarpc.com';
  LoginParams? loginParams;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    // This is important to trigger the on Android.
    if (state == AppLifecycleState.resumed) {
      Web3AuthFlutter.setCustomTabsClosed();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final themeMap = HashMap<String, String>();
    themeMap['primary'] = "#F5820D";

    String redirectUrl;
    if (Platform.isAndroid) {
      redirectUrl = 'w3a://com.example.w3aflutter';
    } else if (Platform.isIOS) {
      redirectUrl = 'com.example.w3aflutter://openlogin';
    } else {
      throw UnKnownException('Unknown platform');
    }

    final authConnectionConfig = [
      AuthConnectionConfig(
        authConnection: AuthConnection.custom,
        authConnectionId: "w3a-firebase-demo",
        clientId:
            "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ",
      ),
    ];

    await Web3AuthFlutter.init(
      Web3AuthOptions(
        clientId:
            'BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ',
        web3AuthNetwork: Web3AuthNetwork.sapphire_mainnet,
        redirectUrl: redirectUrl,
        whiteLabel: WhiteLabelData(
          appName: "Web3Auth Flutter App",
          logoLight:
              "https://www.vectorlogo.zone/logos/flutterio/flutterio-icon.svg",
          logoDark:
              "https://cdn.icon-icons.com/icons2/2389/PNG/512/flutter_logo_icon_145273.png",
          defaultLanguage: Language.en,
          mode: ThemeModes.auto,
          appUrl: "https://web3auth.io",
          useLogoLoader: true,
          theme: themeMap,
        ),
        authConnectionConfig: authConnectionConfig,
        chains: [
          Chains(
            chainId: "0x1",
            rpcTarget: rpcUrl,
            displayName: "Ethereum Mainnet",
            ticker: "ETH",
          ),
        ],
        defaultChainId: "0x1",
        // 259200 allows user to stay authenticated for 3 days with Web3Auth.
        // Default is 86400, which is 1 day.
        sessionTime: 259200,
      ),
    );

    try {
      await Web3AuthFlutter.initialize();
    } catch (e) {
      log(e.toString());
    }

    final String res = await Web3AuthFlutter.getPrivateKey();
    log(res);
    if (res.isNotEmpty) {
      setState(() {
        logoutVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('W3A Flutter (JWT) Firebase Example'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                Visibility(
                  visible: !logoutVisible,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.flutter_dash,
                        size: 80,
                        color: Color(0xFF1389fd),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      const Text(
                        'Web3Auth',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: Color(0xFF0364ff),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Welcome to Web3Auth Flutter (JWT) Firebase Example',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Login with',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 245, 130, 13),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _login(_loginWithFirebase),
                        child: const Text('Login with Firebase'),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: logoutVisible,
                  child: ElevatedButtonTheme(
                    data: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 195, 47, 233),
                        foregroundColor: Colors.white, // This is what you need!
                      ),
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: ElevatedButton(
                              // This is what you need!
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _logout(),
                              child: const Column(
                                children: [
                                  Text('Logout'),
                                ],
                              )),
                        ),
                        const Text(
                          'Blockchain calls',
                          style: TextStyle(fontSize: 20),
                        ),
                        ElevatedButton(
                          onPressed: _getAddress,
                          child: const Text('Get Address'),
                        ),
                        ElevatedButton(
                          onPressed: _getBalance,
                          child: const Text('Get Balance'),
                        ),
                        ElevatedButton(
                          onPressed: _sendTransaction,
                          child: const Text('Send Transaction'),
                        ),
                        ElevatedButton(
                          onPressed: _launchWalletUI,
                          child: const Text('Launch Wallet UI'),
                        ),
                        ElevatedButton(
                          onPressed: _enableMFA,
                          child: const Text('Enable MFA'),
                        ),
                        ElevatedButton(
                          onPressed: _manageMFA,
                          child: const Text('Manage MFA'),
                        ),
                        ElevatedButton(
                          onPressed: _transactionConfirmationUI,
                          child: const Text('Transaction Confirmation UI'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_result),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  VoidCallback _login(Future<Web3AuthResponse> Function() method) {
    return () async {
      try {
        final Web3AuthResponse response = await method();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'privateKey', response.privateKey?.toString() ?? '');
        setState(() {
          _result = response.toString();
          logoutVisible = true;
        });
      } on UserCancelledException {
        log("User cancelled.");
      } on UnKnownException {
        log("Unknown exception occurred");
      }
    };
  }

  VoidCallback _logout() {
    return () async {
      try {
        setState(() {
          _result = '';
          logoutVisible = false;
        });
        await Web3AuthFlutter.logout();
        await FirebaseAuth.instance.signOut();
      } on UserCancelledException {
        log("User cancelled.");
      } on UnKnownException {
        log("Unknown exception occurred");
      }
    };
  }

  Future<void> _enableMFA() async {
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      if (idToken == null) {
        throw Exception('No user found');
      }
      loginParams = LoginParams(
        authConnection: AuthConnection.custom,
        authConnectionId: "w3a-firebase-demo",
        idToken: idToken,
      );
      await Web3AuthFlutter.enableMFA(loginParams: loginParams!);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _manageMFA() async {
    try {
      await Web3AuthFlutter.manageMFA();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _transactionConfirmationUI() async {
    final result = await Web3AuthFlutter.request(
      "personal_sign",
      [
        "Hello, World!",
        await _getAddress(),
      ],
    );

    log(result.toJson().toString());
  }

  Future<void> _launchWalletUI() async {
    await Web3AuthFlutter.showWalletUI();
  }

  Future<String> _getFirebaseIdToken() async {
    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();
      return await credential.user?.getIdToken(true) ?? '';
    } on FirebaseAuthException catch (e) {
      log('Firebase anonymous sign-in failed: ${e.code} ${e.message}');
      return '';
    }
  }

  Future<Web3AuthResponse> _loginWithFirebase() async {
    final idToken = await _getFirebaseIdToken();

    loginParams = LoginParams(
      authConnection: AuthConnection.custom,
      authConnectionId: "w3a-firebase-demo",
      idToken: idToken,
    );

    return Web3AuthFlutter.connectTo(loginParams!);
  }

  Future<String> _getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString('privateKey') ?? '0';

    final credentials = EthPrivateKey.fromHex(privateKey);
    final address = credentials.address;

    log("Account, ${address.hexEip55}");
    setState(() {
      _result = address.hexEip55.toString();
    });
    return address.hexEip55;
  }

  Future<EtherAmount> _getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString('privateKey') ?? '0';

    final client = Web3Client(rpcUrl, Client());
    final credentials = EthPrivateKey.fromHex(privateKey);
    final address = credentials.address;
    final balance = await client.getBalance(address);
    log(balance.toString());
    setState(() {
      _result = balance.toString();
    });
    return balance;
  }

  Future<String> _sendTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString('privateKey') ?? '0';

    final client = Web3Client(rpcUrl, Client());
    final credentials = EthPrivateKey.fromHex(privateKey);
    final address = credentials.address;
    try {
      final receipt = await client.sendTransaction(
        credentials,
        Transaction(
          from: address,
          to: EthereumAddress.fromHex(
            '0x809D4310d578649D8539e718030EE11e603Ee8f3',
          ),
          // gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 100),
          value: EtherAmount.fromInt(
            EtherUnit.gwei,
            5000000,
          ), // 0.005 ETH
        ),
        chainId: 1,
      );
      log(receipt);
      setState(() {
        _result = receipt;
      });
      return receipt;
    } catch (e) {
      setState(() {
        _result = e.toString();
      });
      return e.toString();
    }
  }
}
