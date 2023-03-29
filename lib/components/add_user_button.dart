import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shca_test/providers/json_provider.dart';
import 'package:shca_test/providers/username_provider.dart';
import 'package:shca_test/screens/family_share_screen.dart';
import 'package:shca_test/screens/map_screen.dart';
import 'package:crypto/crypto.dart';

class AddUser extends ConsumerWidget {
  final String username;
  final UserType userType;

  const AddUser({Key? key, required this.username, required this.userType})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    Future<void> addUser() {
      return users
          .doc(username)
          .set({
            'username': username,
            'userType': userType.toString(),
            'familyCode': sha1.convert(utf8.encode(username)).toString()
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: const Text('Connect'),
        style: ElevatedButton.styleFrom(
          primary: const Color(0xFF0270B8),
          onPrimary: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          ref.read(userDetailsProvider.notifier).state = UserDetails(
              username: ref.watch(userDetailsProvider).username,
              userType: ref.watch(userDetailsProvider).userType);
          addUser();
          // Timer.periodic(const Duration(seconds: 1), (timer) {
          //   var data = {
          //     "gps": {
          //       "latitude": 34.2342 + Random().nextInt(10),
          //       "longitude": 23.893345 + Random().nextInt(10),
          //       "speed": 25 + Random().nextInt(10),
          //       "time": {
          //         "hour": 1,
          //         "minute": 1,
          //         "second": 1 + Random().nextInt(10),
          //       },
          //       "date": {
          //         "month": 1,
          //         "day": 1 + Random().nextInt(10),
          //         "year": 2023,
          //       },
          //     },
          //     "helmet": {
          //       "is_worn": Random().nextInt(10) % 2 == 0,
          //       "alcohol_level": 256 - Random().nextInt(10),
          //     },
          //     "motor": {
          //       "is_ignition_ready": Random().nextInt(10) % 2 == 0,
          //     },
          //     "debug": {
          //       "message": "debug messages",
          //       "source": "from receiver",
          //       "info": "info here",
          //     },
          //   };
          //   ref.read(mockDataProvider.notifier).state = data;
          //   var latitude =
          //       ref.watch(mockDataProvider)['gps']['latitude'] as double;
          //   var longitude =
          //       ref.watch(mockDataProvider)['gps']['longitude'] as double;
          //   // add code here to update the location of the user in the database every 10 seconds
          //   // users.doc(username).update({
          //   //   'latitude': latitude,
          //   //   'longitude': longitude,
          //   //   'timestamp': DateTime.now().toString(),
          //   // });
          // });
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
