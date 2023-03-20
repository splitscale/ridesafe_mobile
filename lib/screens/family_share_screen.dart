import 'package:flutter/material.dart';
import 'package:shca_test/screens/family_map_view_screen.dart';
import 'package:shca_test/providers/username_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FamilyOptionScreen extends ConsumerWidget {
  const FamilyOptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Family Options'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32.0),
          const Text(
            'Enter Location Share Code',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter Code',
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FamilyMapViewScreen(),
                      ),
                    );
                  },
                  child: const Text('Track'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
