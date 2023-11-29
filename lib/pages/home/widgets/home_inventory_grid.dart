import 'package:flutter/material.dart';
import 'package:notes/database_service.dart';
import 'package:notes/providers/blockchain_provider.dart';
import 'package:notes/pages/home/widgets/home_product_details.dart';
import '../../../models/models.dart';
import 'package:provider/provider.dart';

class HomeInventoryGrid extends StatelessWidget {
  const HomeInventoryGrid({super.key});

  int crossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1400) {
      return 3;
    } else if (width > 800) {
      return 2;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    BlockchainProvider blockchainProvider =
        Provider.of<BlockchainProvider>(context);
    return FutureBuilder(
        future: DatabaseService().getUser(blockchainProvider.user.cid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return GridView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount(context), childAspectRatio: 2),
            itemCount: snapshot.data?.products.length ?? 0,
            itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(5),
                child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      showModalBottomSheet(
                          constraints: const BoxConstraints(
                              maxHeight: 700, maxWidth: 1000),
                          isDismissible: true,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return ProductDetails(
                                product: snapshot.data!.products[index]);
                          });
                    },
                    child: InventoryItem(
                        product: snapshot.data!.products[index]))),
          );
        });
  }
}

class InventoryItem extends StatelessWidget {
  const InventoryItem(
      {super.key, required this.product, this.includeDesc = true});
  final Product product;
  final bool includeDesc;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                Expanded(
                    child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(product.batchId)))
              ],
            ),
            Divider(
              color:
                  Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(100),
            ),
            includeDesc
                ? Text(
                    product.desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : Container(),
            const SizedBox(
              height: 10,
            ),
            const Expanded(child: SizedBox()),
            Text(
              "${product.weight} kg",
              style: Theme.of(context).textTheme.titleMedium,
            )
          ],
        ));
  }
}
