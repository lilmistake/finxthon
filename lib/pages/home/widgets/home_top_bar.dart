import 'package:flutter/material.dart';
import 'package:notes/providers/blockchain_provider.dart';
import 'package:provider/provider.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    BlockchainProvider blockchainProvider =
        Provider.of<BlockchainProvider>(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(999)),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: Image.network(
                blockchainProvider.user.pfp,
                width: 75,
                height: 75,
                fit: BoxFit.cover,
              )),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome Back,"),
              FittedBox(
                child: Text(
                  blockchainProvider.user.name,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
