import 'package:flutter/material.dart';
import 'package:notes/pages/home/home_page.dart';
import 'package:notes/providers/blockchain_provider.dart';
import 'package:notes/database_service.dart';
import 'package:notes/models/models.dart';
import 'package:notes/pages/home/widgets/home_inventory_grid.dart';
import 'package:provider/provider.dart';

class Transaction {
  final String batchId;
  final double weight;

  Transaction({required this.batchId, required this.weight});
}

class SellProductDialog extends StatefulWidget {
  const SellProductDialog({super.key});

  @override
  State<SellProductDialog> createState() => _SellProductDialogState();
}

class _SellProductDialogState extends State<SellProductDialog> {
  TextEditingController addressController = TextEditingController();
  List<Product> selectedItems = [];
  List<TextEditingController> controllers = [];
  final GlobalKey<FormState> formKey = GlobalKey();

  showErrorSnackBar(BuildContext context, String data) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(data),
      ),
    );
  }

  void processSale(BuildContext context, List<Transaction> transactions,
      String buyerAddress) async {
    BlockchainProvider blockchainProvider =
        Provider.of<BlockchainProvider>(context, listen: false);

    String buyerCid =
        await blockchainProvider.getInventoryCID(address: buyerAddress);
    User buyer;

    if (buyerCid.isEmpty) {
      if (context.mounted) {
        showErrorSnackBar(context, "User not found");
      }
      return; // This user doesn't exist
    }

    if (buyerCid == blockchainProvider.user.cid) {
      if (context.mounted) {
        showErrorSnackBar(context, "You can't sell to yourself");
      }
      return; // This user doesn't exist
    }
    buyer = await DatabaseService().getUser(buyerCid);

    for (Transaction transaction in transactions) {
      String batchId = transaction.batchId;
      double weight = transaction.weight;

      int i = blockchainProvider.user.products
          .indexWhere((element) => element.batchId == batchId);
      Product avaialble = blockchainProvider.user.products[i];

      blockchainProvider.user.products[i] = blockchainProvider.user.products[i]
          .copyWith(weight: avaialble.weight - weight);

      if (avaialble.weight == weight) {
        blockchainProvider.user.products.removeAt(i);
      }

      int j =
          buyer.products.indexWhere((element) => element.batchId == batchId);
      if (j == -1) {
        buyer.products.add(avaialble.copyWith(weight: weight));
        j = buyer.products.length - 1;
      } else {
        buyer.products[j] = buyer.products[j]
            .copyWith(weight: buyer.products[j].weight + weight);
      }

      ProductChain availableChain = avaialble.toChain();

      List<ProductChain> rawMaterials = [];
      for (Product rawProduct in blockchainProvider.user.products
          .where((element) => avaialble.rawMaterials.contains(element.name))) {
        if (rawProduct.rawMaterials.isEmpty || rawProduct.chainCid == null) {
          // this means first layer, return chain as it is
          rawMaterials.add(rawProduct.toChain());
        } else {
          var response = await DatabaseService().getData(rawProduct.chainCid!);
          if (response == null) continue;
          rawMaterials.add(ProductChain.fromJson(response));
          // If raw material has raw materials, it MUST have a chainCid
          // delete prods that have no chainCid but raw materials
          // this means it has raw materials that need to be fetched
          // fetch from it's chain and return ProductChain object from that
        }
      }
      print(availableChain.toJson());
      availableChain = availableChain.copyWith(
        createdTs: DateTime.now().millisecondsSinceEpoch,
        weight: buyer.products[j].weight,
        rawMaterials: [availableChain.copyWith(rawMaterials: rawMaterials)],
      );
      var newChainCid =
          await DatabaseService().addFile(availableChain.toJson());
      print(newChainCid);

      String? sellerNewCid =
          await DatabaseService().addFile(blockchainProvider.user.toJson());
      String? buyerNewCid = await DatabaseService().addFile(buyer.toJson());

      if (sellerNewCid == null || buyerNewCid == null) {
        continue;
      }
      buyerCid = buyerNewCid;
      blockchainProvider.user.cid = sellerNewCid;
    }
    if (context.mounted) {
      showErrorSnackBar(context, "Transaction Completed Successsfully");
    }
    await blockchainProvider.updateInventoryCID();
    await blockchainProvider.updateInventoryCID(
        newCid: buyerCid, address: buyerAddress);

    //0x775c3FF1D7196d887e3eAC2EdE5138d6B6D294F6
  }

  handleSubmit() {
    if (selectedItems.isEmpty) return;
    if (!formKey.currentState!.validate()) return;
    List<Transaction> transactions = [];
    for (var element in controllers) {
      if (element.text.isNotEmpty) {
        transactions.add(Transaction(
            batchId: selectedItems[controllers.indexOf(element)].batchId,
            weight: double.parse(element.text)));
      }
    }

    Navigator.pop(context);
    processSale(context, transactions, addressController.text);
  }

  Widget proceedButtons() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      child: Flex(
        direction: screenSize(context) == ScreenSize.large
            ? Axis.horizontal
            : Axis.vertical,
        children: [
          Text(
            "Receiver Address: ",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: 500,
            child: TextFormField(
              controller: addressController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a valid address";
                }
                RegExp regExp = RegExp(r"^(0x)?[0-9a-fA-F]{40}$",
                    caseSensitive: false, multiLine: false);
                if (!regExp.hasMatch(value.trim())) {
                  return "Please enter a valid address";
                }
                return null;
              },
              style: Theme.of(context).textTheme.titleMedium,
              decoration: const InputDecoration(
                  hintStyle: TextStyle(fontWeight: FontWeight.w100),
                  hintText: "0x449b81Bf5EA7A91585b43c7706E2159c63b19505"),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> quantitySelectors() {
    if (selectedItems.isEmpty) return [];

    List<Widget> items = [
      const SizedBox(
        height: 20,
      ),
      Row(
        children: [
          Expanded(
              child: Text(
            "Product Name",
            style: Theme.of(context).textTheme.titleMedium,
          )),
          ...screenSize(context) == ScreenSize.large
              ? [
                  Expanded(
                      child: Text(
                    "Batch ID",
                    style: Theme.of(context).textTheme.titleMedium,
                  )),
                  Expanded(
                      child: Text(
                    "Available",
                    style: Theme.of(context).textTheme.titleMedium,
                  )),
                ]
              : [],
          Expanded(
              child: Text(
            "Weight (in kgs)",
            style: Theme.of(context).textTheme.titleMedium,
          )),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      const Divider(),
      const SizedBox(
        height: 10,
      ),
      ...selectedItems.map((e) {
        return Row(
          children: [
            Expanded(child: Text(e.name)),
            ...screenSize(context) == ScreenSize.large
                ? [
                    Expanded(child: Text(e.batchId)),
                    Expanded(child: Text(e.weight.toString())),
                  ]
                : [],
            Expanded(
                child: TextFormField(
                    controller: controllers[selectedItems.indexOf(e)],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return "Please enter a valid weight";
                      }
                      if (e.weight < double.parse(value)) {
                        return "Weight cannot be greater than ${e.weight}";
                      }
                      return null;
                    }))
          ],
        );
      }).toList(),
      const SizedBox(
        height: 20,
      ),
    ];
    return items;
  }

  List<Widget> productsGrid(context, BlockchainProvider blockchainProvider) {
    return blockchainProvider.user.products
        .map((product) => Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 2,
                      color: selectedItems.contains(product)
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(15)),
              width: 350,
              height: 120,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  setState(() {
                    if (selectedItems.contains(product)) {
                      selectedItems.remove(product);
                      controllers.removeAt(0);
                      return;
                    }
                    selectedItems.add(product);
                    controllers.add(TextEditingController());
                  });
                },
                child: InventoryItem(
                  product: product,
                  includeDesc: false,
                ),
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    BlockchainProvider blockchainProvider =
        Provider.of<BlockchainProvider>(context);
    return Dialog(
        insetPadding: const EdgeInsets.all(10),
        backgroundColor: Theme.of(context).colorScheme.background,
        surfaceTintColor: Theme.of(context).colorScheme.background,
        child: Container(
            width: 1200,
            padding: const EdgeInsets.all(20),
            child: IntrinsicHeight(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Text(
                              "Sell Product",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const VerticalDivider(),
                            Expanded(
                                child: screenSize(context) == ScreenSize.large
                                    ? proceedButtons()
                                    : const SizedBox()),
                            const CloseButton()
                          ],
                        ),
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          direction: Axis.horizontal,
                          children: productsGrid(context, blockchainProvider),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ...quantitySelectors(),
                      screenSize(context) == ScreenSize.large
                          ? const SizedBox()
                          : proceedButtons(),
                      Container(
                        margin: const EdgeInsets.all(15),
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: handleSubmit,
                          child: const Text("Continue"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )));
  }
}
