import 'package:flutter/material.dart';
import 'package:notes/pages/account/account_page.dart';
import 'package:notes/providers/blockchain_provider.dart';
import 'package:notes/providers/theme_provider.dart';
import 'package:provider/provider.dart';
//finxthon@64.227.136.99
//http://64.227.136.99:5001/ipfs/bafybeiamycmd52xvg6k3nzr6z3n33de6a2teyhquhj4kspdtnvetnkrfim/#/
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (context) => BlockchainProvider(),
      ),
      ChangeNotifierProvider(create: (context) => ThemeProvider())
    ], child: const Root());
  }
}

class Root extends StatelessWidget {
  const Root({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    BlockchainProvider blockchainProvider =
        Provider.of<BlockchainProvider>(context);
    return MaterialApp(
        theme: theme(themeProvider),
        debugShowCheckedModeBanner: false,
        home: blockchainProvider.isInitializing
            ? const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              )
            : const AccountPage());
  }
}