import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:notes/models/user_model.dart';
import 'package:web_socket_channel/io.dart';

import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

class BlockchainProvider extends ChangeNotifier {
  // host to a server
  late User user;
  late EthereumAddress userAddress;

  ///
  /* final String _rpcUrl = 'http://127.0.0.1:8545';
  final String _wsUrl = 'ws://127.0.0.1:8545'; */

  final String _rpcUrl = 'http://64.227.136.99:8545';
  final String _wsUrl = 'ws://64.227.136.99:8545';
  late Web3Client _web3client;

  late EthPrivateKey _credentials;

  // all transactions will be charged from this account.
  final String _privatekey =
      "0x4c74191da59310fb5e6388983a5f54dfa2d4dd711639bc2079f86aba849fdf01";
  late DeployedContract _deployedContract;
  late ContractFunction _updateInventoryCID;
  late ContractFunction _getinventoryCID;

  bool isLoading = false;
  bool isInitializing = true;

  BlockchainProvider() {
    init();
  }

  init() async {
    _web3client = Web3Client(_rpcUrl, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });
    await getDeployedContract();
    await generateCredentials();
    isInitializing = false;
    notifyListeners();
  }

  Future<void> getDeployedContract() async {
    String abiFile =
        await rootBundle.loadString('build/contracts/InventoryContract.json');
    var jsonABI = jsonDecode(abiFile);

    ContractAbi abiCode =
        ContractAbi.fromJson(jsonEncode(jsonABI['abi']), 'InventoryContract');
    EthereumAddress contractAddress =
        EthereumAddress.fromHex(jsonABI["networks"]["5777"]["address"]);

    _deployedContract = DeployedContract(abiCode, contractAddress);

    _updateInventoryCID = _deployedContract.function('updateInventoryCID');
    _getinventoryCID = _deployedContract.function('getInventoryCID');
  }

  Future<void> generateCredentials() async {
    _credentials = EthPrivateKey.fromHex(_privatekey);
  }

  void setUser(User newUser) {
    user = newUser;
    notifyListeners();
  }

  Future<String> getInventoryCID({String? address}) async {
    EthereumAddress a;
    if (address == null) {
      a = userAddress;
    } else {
      try {
        a = EthereumAddress.fromHex(address);
      } catch (e) {
        return "";
      }
    }
    print(a);

    var response = await _web3client.call(
        contract: _deployedContract, function: _getinventoryCID, params: [a]);
    print("RECEIVED CID FROM BLOCKCHAIN: ${response[0]}");

    return response[0];
  }

  // Updates the inventory CID of the user, if CID not given, updates current user's CID.
  Future<void> updateInventoryCID({String? address, String? newCid}) async {
    EthereumAddress a;
    if (address == null) {
      a = userAddress;
    } else {
      a = EthereumAddress.fromHex(address);
    }

    await _web3client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _deployedContract,
          function: _updateInventoryCID,
          parameters: [a, newCid ?? user.cid],
        ),
        chainId: 1337,
        fetchChainIdFromNetworkId: false);

    notifyListeners();

    print("NEW INVENTORY CID: ${newCid ?? user.cid}");
  }
}

/* 
Producers list their products on marketplace,

Aim: Create a history of the product
Can also use geolocation


Problem: Tracking products is very difficult
With this app, I want to be able to track where my goods are right now,
I also want the end user to be able to track the sources and everything related to
that product
I also want 3rd part organizations to add their inputs to it.

Maybe can make a marketplace for this?




shampoo company

class

class SmartContract{
  String itemName;
  double quantityInKgs;  
}

class OwnershipDetails{
  String ownerId;
  St
}

List<Material> rawMaterials[]


Chewing Gum example - 
10kg Rubber
10kg cane
10kg sugar
10kg color
5kg packaging
10kg falvouring


{
  RUB123
  rubber,
  100kg,
  Rohit,
  Uttar Pradesh,
  1 Aug,
  Raw: []
},
{
  CANE123,
  sugar cane,
  100kg,
  Amit,
  Bihar,
  30 July,
  Raw: []
}
{
  SUG123,
  sugar,
  100kg,
  Rajesh,
  Madhya Pradesh,
  7 Aug,
  Raw: [CANE123]
}
{
  DISTL,
  distilled water,
  100kg,
  Yadav,
  Gujarat,
  11 Aug,
  Raw:[]
}
{
  SYR,
  sugar syrup,
  100kg,
  Kumar,
  Madhya Pradesh,
  10 Aug,
  Raw: [SUG123, DISTL]
}
{
  GUM,
  bubble gum,
  10kg,
  Center Fresh Pvt Ltd.
  Rajasthan,
  15 Aug,
  Raw: [RUB123, SYR: [SUG123: [CANE123], DISTL]]
}

For creating a new product and adding it to the chain,
either it is the first member in the chain, or it needs to list its sources.


---
---
---
---
---
---
---
---


- Login

- Create Product ✅
  - Fill a form, use products from your inventory
  - Upload to IPFS ✅
  - Set CID in blockchain ✅

- Sell Product 
  - Fill a form, add email/public key of user you're selling to
  - Update user inventory ✅
  - Update buyer inventory ✅
  - Create transaction record, Save to IPFS, Add CID to Blockchain

- Track Product
  - Scan Barcode/QR code
  - Query details from IPFS
  - Render as a tree

 */
