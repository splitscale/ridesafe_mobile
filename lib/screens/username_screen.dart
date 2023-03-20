import 'package:flutter/material.dart';
import 'package:shca_test/screens/family_share_screen.dart';
import 'package:shca_test/screens/map_screen.dart';
import 'package:shca_test/providers/username_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsernameScreen extends ConsumerWidget {
  const UsernameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var userDetails = ref.watch(userDetailsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('RideSafe'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter Username',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 250,
              child: TextField(
                onChanged: (value) {
                  ref.read(userDetailsProvider.notifier).state = UserDetails(
                      username: value, userType: userDetails.userType);
                },
                decoration: const InputDecoration(
                  hintText: 'Username',
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Choose Selection',
              style: TextStyle(fontSize: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Radio<UserType>(
                    value: UserType.driver,
                    groupValue: ref.watch(userDetailsProvider).userType,
                    onChanged: (value) {
                      ref.read(userDetailsProvider.notifier).state =
                          UserDetails(
                              username: ref.watch(userDetailsProvider).username,
                              userType: value!);
                    }),
                const Text('Driver'),
                const SizedBox(width: 32),
                Radio<UserType>(
                  value: UserType.family,
                  groupValue: ref.watch(userDetailsProvider).userType,
                  onChanged: (value) {
                    ref.read(userDetailsProvider.notifier).state = UserDetails(
                        username: ref.watch(userDetailsProvider).username,
                        userType: value!);
                  },
                ),
                const Text('Family'),
              ],
            ),
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                child: const Text('Connect'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ref.watch(userDetailsProvider).userType ==
                                      UserType.driver
                                  ? const MapScreen()
                                  : const FamilyOptionScreen()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
