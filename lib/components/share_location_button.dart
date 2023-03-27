import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shca_test/providers/username_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShareLiveLocationButton extends ConsumerWidget {
  const ShareLiveLocationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var userDetails = ref.watch(userDetailsProvider);
    return ElevatedButton(
        // width is less
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(100, 30),
          backgroundColor: Color.fromARGB(255, 48, 152, 255),
        ),
        onPressed: () async {
          await Share.share(
            ref.watch(userDetailsProvider).username,
            subject: 'Live Location',
            sharePositionOrigin: const Rect.fromLTWH(0, 0, 0, 0),
          );
        },
        child: const Text('Share Live Location',
            style: TextStyle(fontSize: 14.0)));
  }
}
