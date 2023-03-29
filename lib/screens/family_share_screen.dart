import 'package:flutter/material.dart';
import 'package:shca_test/screens/family_map_view_screen.dart';
import 'package:shca_test/providers/username_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyOptionScreen extends StatefulWidget {
  const FamilyOptionScreen({Key? key}) : super(key: key);

  @override
  State<FamilyOptionScreen> createState() => _FamilyOptionScreenState();
}

class _FamilyOptionScreenState extends State<FamilyOptionScreen> {
  final TextEditingController _familyCodeController = TextEditingController();
  String _familyCode = '';

  Future<void> _onTrackPressed() async {
    final familyCode = _familyCodeController.text;
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('familyCode', isEqualTo: familyCode)
        .get();
    final doc = docSnapshot.docs.first;
    var latitude = doc.data()['latitude'];
    var longitude = doc.data()['longitude'];
    var name = doc.data()['username'];
    if (doc != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FamilyMapViewScreen(
            name: name,
            latitude: latitude,
            longitude: longitude,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Invalid Code'),
            content: const Text('The family code you entered is invalid.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _familyCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 2, 56, 110),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: TextField(
              controller: _familyCodeController,
              onChanged: (value) {
                setState(() {
                  _familyCode = value;
                });
              },
              decoration: const InputDecoration(
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
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(200, 50),
                    backgroundColor: const Color.fromARGB(255, 2, 56, 110),
                  ),
                  onPressed: _onTrackPressed,
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
