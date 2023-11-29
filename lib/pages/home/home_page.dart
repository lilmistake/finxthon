import 'package:flutter/material.dart';
import 'package:notes/pages/home/widgets/home_left_screen.dart';
import 'package:notes/pages/home/widgets/home_right_screen.dart';

ScreenSize screenSize(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  if (width < 500) {
    return ScreenSize.small;
  } else if (width < 1000) {
    return ScreenSize.mid;
  }
  return ScreenSize.large;
}

enum ScreenSize { small, mid, large }

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    ScreenSize size = screenSize(context);
    return Scaffold(
      appBar: size == ScreenSize.large ? null : AppBar(title: const Text("My Inventory")),
      drawer: size == ScreenSize.large
          ? null
          : const Drawer(child: HomeLeftSideScreen()),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  size == ScreenSize.large
                      ? const Expanded(flex: 1, child: HomeLeftSideScreen())
                      : const SizedBox(),
                  const Expanded(
                    flex: 3,
                    child: HomeRightSideScreen(),
                  ),
                ],
              ))),
    );
  }
}
