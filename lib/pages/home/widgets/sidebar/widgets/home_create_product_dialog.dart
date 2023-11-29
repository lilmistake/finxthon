import 'package:flutter/material.dart';
import 'package:notes/models/models.dart';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:notes/pages/home/home_page.dart';
import 'package:notes/providers/blockchain_provider.dart';
import 'package:notes/database_service.dart';
import 'package:notes/models/product_model.dart';
import 'package:provider/provider.dart';

class HomeCreateProductDialog extends StatefulWidget {
  const HomeCreateProductDialog({super.key});

  @override
  State<HomeCreateProductDialog> createState() =>
      _HomeCreateProductDialogState();
}

class _HomeCreateProductDialogState extends State<HomeCreateProductDialog> {
  createProduct(Product product) async {
    BlockchainProvider blockchainProvider =
        Provider.of<BlockchainProvider>(context, listen: false);
    blockchainProvider.user.products.add(product);
    String? cid =
        await DatabaseService().addFile(blockchainProvider.user.toJson());
    if (cid == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Something went wrong, please try again later")));
      }
      blockchainProvider.user.products.removeLast();
      return;
    }
    blockchainProvider.user.cid = cid;
    await blockchainProvider.updateInventoryCID();
    if (context.mounted) Navigator.pop(context);
  }

  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  LatLng latLng = const LatLng(28.4727152, 77.4880189);
  List<Product> selectedRawMaterials = [];

  setLatLng(LatLng latLng) {
    setState(() {
      this.latLng = latLng;
    });
  }

  handleSubmit() async {
    if (!formKey.currentState!.validate()) return;
    String randomString1 = DateTime.now()
        .millisecondsSinceEpoch
        .toRadixString(36)
        .split("")
        .reversed
        .join("");
    String randomString2 = Random().nextInt(1000000).toRadixString(36);
    String batchId = "BATCH-$randomString1-$randomString2";

    // if has raw materials, create chainCid
    // for that,

    Product newProduct = Product(
        batchId: batchId,
        name: nameController.value.text,
        desc: descController.value.text,
        weight: double.parse(weightController.value.text),
        createdTs: DateTime.now().millisecondsSinceEpoch,
        location: [latLng.latitude, latLng.longitude],
        rawMaterials: selectedRawMaterials.map((e) => e.batchId).toList());
    if (selectedRawMaterials.isEmpty) {
      createProduct(newProduct);
      return;
    }

    ProductChain chain = newProduct.toChain();

    List<ProductChain> rawMaterials = [];
    for (Product rawProduct in selectedRawMaterials) {
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
    chain = chain.copyWith(rawMaterials: rawMaterials);
    var newChainCid = await DatabaseService().addFile(chain.toJson());
    print("NEW CHAIN CID:  $newChainCid");
    newProduct = newProduct.copyWith(chainCid: newChainCid);
    createProduct(newProduct);
  }

  @override
  Widget build(BuildContext context) {
    BlockchainProvider blockchainProvider =
        Provider.of<BlockchainProvider>(context);
    return Dialog(
        insetPadding: const EdgeInsets.all(10),
        backgroundColor: Theme.of(context).colorScheme.background,
        surfaceTintColor: Theme.of(context).colorScheme.background,
        child: IntrinsicHeight(
          child: SizedBox(
              width: 1200,
              height: 700,
              child: Form(
                key: formKey,
                child: Flex(
                  direction: screenSize(context) == ScreenSize.large
                      ? Axis.horizontal
                      : Axis.vertical,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: double.infinity,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: latLng,
                              initialZoom: 12,
                              onPositionChanged: (p, z) {
                                if (p.center != null) {
                                  setLatLng(p.center!);
                                }
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              const _MapCenterPointer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Create Product",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                  const CloseButton()
                                ],
                              ),
                              const Divider(),
                              Text(
                                "Product Details",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                },
                                controller: nameController,
                                decoration: InputDecoration(
                                    label: const Text("Name of Product"),
                                    alignLabelWithHint: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                },
                                controller: descController,
                                maxLines: 5,
                                minLines: 3,
                                decoration: InputDecoration(
                                    label: const Text(
                                        "Description of the Product"),
                                    alignLabelWithHint: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "This field is required";
                                  } else if (double.tryParse(value) == null ||
                                      double.parse(value) <= 0) {
                                    return "Please enter a valid weight";
                                  }
                                  return null;
                                },
                                controller: weightController,
                                decoration: InputDecoration(
                                    label: const Text("Weight (in kgs)"),
                                    alignLabelWithHint: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Raw Material Used",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Text(
                                  "Select the raw materials used to make this product from your inventory, scroll for more options"),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.all(8),
                                height: 100,
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  child: _rawMaterialSelectMenu(
                                      blockchainProvider, context),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              ElevatedButton(
                                  onPressed: handleSubmit,
                                  child: const Text("Create"))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }

  Wrap _rawMaterialSelectMenu(
      BlockchainProvider blockchainProvider, BuildContext context) {
    return Wrap(
        children: blockchainProvider.user.products
            .map((e) => InkWell(
                  onTap: () {
                    setState(() {
                      if (selectedRawMaterials.contains(e)) {
                        selectedRawMaterials.remove(e);
                      } else {
                        selectedRawMaterials.add(e);
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 5, bottom: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(selectedRawMaterials.contains(e)
                                    ? 1
                                    : 0.2))),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    child: Text(
                      e.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ))
            .toList());
  }
}

class _MapCenterPointer extends StatelessWidget {
  const _MapCenterPointer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: Colors.red,
        ),
        width: 10,
        height: 10,
      ),
    );
  }
}
