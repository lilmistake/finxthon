import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:notes/models/models.dart';
import 'package:notes/pages/home/home_page.dart';
import 'package:notes/pages/home/widgets/sidebar/widgets/home_sell_product_dialog.dart';
import 'package:notes/pages/home/widgets/sidebar/home_track_product_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key, required this.product});
  final Product product;

  qrCode(context) {
    if (product.chainCid != null) {
      return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            QrImageView(
              data: product.chainCid!,
              version: QrVersions.auto,
              backgroundColor: Colors.white,
              size: 200.0,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text("See product history using this QR code "),
            FittedBox(child: Text(product.chainCid!))
          ],
        ),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Flex(
            direction: screenSize(context) == ScreenSize.large
                ? Axis.horizontal
                : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AbsorbPointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: FlutterMap(
                          options: MapOptions(
                              initialCenter: LatLng(product.location.first,
                                  product.location.last),
                              initialZoom: 10,
                              interactionOptions: const InteractionOptions(
                                enableScrollWheel: false,
                              )),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(99),
                                  color: Colors.red,
                                ),
                                width: 10,
                                height: 10,
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              Text(product.batchId)
                            ],
                          ),
                        ),
                        Divider(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.2),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(product.desc)),
                        Divider(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.2),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        product.rawMaterials.isEmpty
                            ? const SizedBox()
                            : Text(
                                "Raw Materials Used",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                        Wrap(
                          children: product.rawMaterials
                              .map((e) => Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface),
                                    margin: const EdgeInsets.only(
                                        right: 5, bottom: 5),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    child: Text(
                                      e,
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        qrCode(context),
                        const SizedBox(
                          height: 20,
                        ),
                        _ProductActions(product: product)
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

class _ProductActions extends StatelessWidget {
  const _ProductActions({
    required this.product,
  });

  final Product product;

  Widget viewHistory(context) => ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(PageRouteBuilder(pageBuilder: (a, c, s) {
          return ProductHistory(cid: product.chainCid!);
        }));
      },
      child: const FittedBox(child: Text("View Product History")));

  Widget sellProduct(context) => ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (context) {
              return const SellProductDialog();
            });
      },
      child: const FittedBox(child: Text("Sell this Product")));

  @override
  Widget build(BuildContext context) {
    if (product.chainCid == null) {
      return Center(
        child: sellProduct(context),
      );
    }
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: viewHistory(context)),
          Expanded(child: sellProduct(context))
        ],
      ),
    );
  }
}
