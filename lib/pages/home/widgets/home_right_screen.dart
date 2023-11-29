import 'package:flutter/material.dart';
import 'package:notes/pages/home/home_page.dart';
import 'package:notes/pages/home/widgets/home_inventory_grid.dart';

class HomeRightSideScreen extends StatelessWidget {
  const HomeRightSideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...screenSize(context) == ScreenSize.large
                  ? [
                      Text(
                        "My Inventory",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider()),
                    ]
                  : [
                      const SizedBox(),
                    ],
              const HomeInventoryGrid(),
            ],
          ),
        ));
  }
}
