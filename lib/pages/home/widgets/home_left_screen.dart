import 'package:flutter/material.dart';
import 'package:notes/pages/account/account_page.dart';
import 'package:notes/pages/home/widgets/home_top_bar.dart';
import 'package:notes/pages/home/widgets/sidebar/home_create_product_button.dart';
import 'package:notes/pages/home/widgets/sidebar/home_sell_product_button.dart';
import 'package:notes/pages/home/widgets/sidebar/home_track_product_button.dart';
import 'package:notes/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class HomeLeftSideScreen extends StatelessWidget {
  const HomeLeftSideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TopBar(),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
            Text(
              "Quick Actions",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 20,
            ),
            const CreateProductButton(),
            const SellProductButton(),
            const TrackProductButton(),
            const Expanded(child: SizedBox()),
            const _LogoutButton(),
            const SizedBox(
              height: 10,
            ),
            const _ChangeThemeButton()
          ],
        ));
  }
}

class _ChangeThemeButton extends StatelessWidget {
  const _ChangeThemeButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () =>
          Provider.of<ThemeProvider>(context, listen: false).changeTheme(),
      child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Provider.of<ThemeProvider>(context).brightness == Brightness.light
                  ? const Icon(Icons.dark_mode)
                  : const Icon(Icons.light_mode),
              const SizedBox(width: 10),
              const Text("Change theme"),
            ],
          )),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
          return const AccountPage();
        }));
      },
      child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          child: const Row(
            children: [
              Icon(Icons.logout_rounded),
              SizedBox(width: 10),
              Text("Logout"),
            ],
          )),
    );
  }
}
