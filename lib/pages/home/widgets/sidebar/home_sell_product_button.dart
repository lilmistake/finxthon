import 'package:flutter/material.dart';
import 'package:notes/pages/home/widgets/sidebar/widgets/home_sell_product_dialog.dart';

class SellProductButton extends StatelessWidget {
  const SellProductButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return const SellProductDialog();
              });
        },
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.sell),
              SizedBox(
                width: 10,
              ),
              Text("Sell Product")
            ],
          ),
        ),
      ),
    );
  }
}
