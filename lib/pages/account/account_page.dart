import 'package:flutter/material.dart';
import 'package:notes/providers/blockchain_provider.dart';
import 'package:notes/database_service.dart';
import 'package:notes/models/models.dart';
import 'package:notes/pages/home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

List<String> testAddresses = [
  "0x05F031B6FE7c0a1b7BF3E5da7B5e063D7D43A535", // Rohit Garg
  "0x07d5b4972d1ACC8252CdD955460C1006b241E563", // Rakesh Kumar
  "0x6aff2F0A2a967665b9d603b671Cfd2FD204c5C00" // Shalini Kumari
];

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool fetchedMeta = false;
  List<User> accounts = [];
  Map<String, EthereumAddress> cidToAddressMap = {};

  addressToUserMeta(BlockchainProvider blockchainProvider) async {
    for (int i = 0; i < testAddresses.length; i++) {
      String? cid =
          await blockchainProvider.getInventoryCID(address: testAddresses[i]);

      print(cid);
      User user;
      if (cid.isEmpty) {
        user = User(
            name: "New User",
            pfp:
                "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png",
            cid: "");
        cid = await DatabaseService().addFile(user.toJson());
        print("INSERTED NEW USER IN $cid");
        if (cid == null) continue;
        user.cid = cid;
        blockchainProvider.updateInventoryCID(
            address: testAddresses[i], newCid: cid);
      } else {
        user = await DatabaseService().getUser(cid);
      }
      cidToAddressMap[user.cid] = EthereumAddress.fromHex(testAddresses[i]);
      accounts.add(user);
    }
    setState(() {
      fetchedMeta = true;
    });
  }

  @override
  void didChangeDependencies() {
    BlockchainProvider blockchainProvider =
        Provider.of<BlockchainProvider>(context, listen: false);
    if (!fetchedMeta) {
      addressToUserMeta(blockchainProvider);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        width: 500,
        height: 500,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10)),
        child: fetchedMeta
            ? Column(
                children: [
                  Text(
                    "Choose an Account",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ...accounts
                      .map((e) => _AccountContainer(
                            user: e,
                            address: cidToAddressMap[e.cid]!,
                          ))
                      .toList()
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    )));
  }
}

class _AccountContainer extends StatelessWidget {
  const _AccountContainer({required this.user, required this.address});
  final User user;
  final EthereumAddress address;

  @override
  Widget build(BuildContext context) {
    BlockchainProvider blockchainProvider =
        Provider.of<BlockchainProvider>(context, listen: false);
    return InkWell(
      onTap: () {
        blockchainProvider.userAddress = address;
        blockchainProvider.setUser(user);
        Navigator.of(context).pop();
        Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
          return const HomePage();
        }));
      },
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.background),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(5),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Image.network(
                    user.pfp,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                  )),
              const SizedBox(
                width: 10,
              ),
              Text(
                user.name,
                style: Theme.of(context).textTheme.titleMedium,
              )
            ],
          )),
    );
  }
}
