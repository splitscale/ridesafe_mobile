import 'package:shca_test/screens/family_share_screen.dart';
import 'package:shca_test/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shca_test/providers/username_provider.dart';

// Import the firebase_core and cloud_firestore plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUser extends ConsumerWidget {
  final String username;
  final UserType userType;

  const AddUser({super.key, required this.username, required this.userType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create a CollectionReference called users that references the firestore collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    Future<void> addUser() {
      // Call the user's CollectionReference to add a new user
      // check if username exists
      // if it does, then update the userType
      // if it doesn't, then add the user
      return users
          .doc(username)
          .set({
            'username': username,
            'userType': userType.toString(),
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ElevatedButton(
        child: const Text('Connect'),
        onPressed: () {
          addUser();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ref.watch(userDetailsProvider).userType == UserType.driver
                          ? const MapScreen()
                          : const FamilyOptionScreen()));
        },
      ),
    );
  }
}
