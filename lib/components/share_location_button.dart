import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shca_test/providers/username_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ShareLiveLocationButton extends ConsumerWidget {
  const ShareLiveLocationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var userDetails = ref.watch(userDetailsProvider);
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // get user familyCode
    Future<String> getFamilyCode() async {
      var familyCode = '';
      await users
          .doc(userDetails.username)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          familyCode = data['familyCode'] as String;
        }
      });
      return familyCode;
    }

    return ElevatedButton(
        // width is less
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(100, 30),
          backgroundColor: Color.fromARGB(255, 48, 152, 255),
        ),
        onPressed: () async {
          var familyCode = await getFamilyCode();
          await Share.share(
            familyCode,
            subject: 'Live Location',
            sharePositionOrigin: const Rect.fromLTWH(0, 0, 0, 0),
          );
        },
        child: const Text('Share Live Location',
            style: TextStyle(fontSize: 12.0)));
  }
}
