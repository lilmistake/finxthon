import 'package:flutter/material.dart';
import 'package:notes/pages/home/widgets/sidebar/widgets/home_create_product_dialog.dart';

class CreateProductButton extends StatelessWidget {
  const CreateProductButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          showDialog(
              context: context, builder: (c) => const HomeCreateProductDialog());
        },
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.add),
              SizedBox(
                width: 10,
              ),
              Text("Create Product")
            ],
          ),
        ),
      ),
    );
  }
}