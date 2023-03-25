import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shca_test/screens/map_screen.dart';

import 'package:shca_test/providers/username_provider.dart';
import 'package:shca_test/providers/json_provider.dart';

class UsernameScreen extends ConsumerWidget {
  const UsernameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var userDetails = ref.watch(userDetailsProvider);
    var mockData = ref.watch(mockDataProvider);

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
                    ref.read(userDetailsProvider.notifier).state = UserDetails(
                        username: ref.watch(userDetailsProvider).username,
                        userType: value!);
                  },
                ),
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
            ElevatedButton(
              onPressed: () {
                Timer.periodic(const Duration(seconds: 1), (timer) {
                  var data = {
                    "gps": {
                      "latitude": 34.2342 + Random().nextInt(10),
                      "longitude": 23.893345 + Random().nextInt(10),
                      "speed": 25 + Random().nextInt(10),
                      "time": {
                        "hour": 1,
                        "minute": 1,
                        "second": 1 + Random().nextInt(10),
                      },
                      "date": {
                        "month": 1,
                        "day": 1 + Random().nextInt(10),
                        "year": 2023,
                      },
                    },
                    "helmet": {
                      "is_worn": Random().nextInt(10) % 2 == 0,
                      "alcohol_level": 256 - Random().nextInt(10),
                    },
                    "motor": {
                      "is_ignition_ready": Random().nextInt(10) % 2 == 0,
                    },
                    "debug": {
                      "message": "debug messages",
                      "source": "from receiver",
                      "info": "info here",
                    },
                  };
                  ref.read(mockDataProvider.notifier).state = data;
                });
              },
              child: const Text('Connect'),
            ),
            ElevatedButton(
              onPressed: () {
                // stop the stream

                ref.read(mockDataProvider.notifier).state = {};
              },
              child: const Text('Disconnect'),
            ),
            Expanded(child: Container()),
            ElevatedButton(
              onPressed: () {
                ref.read(userDetailsProvider.notifier).state = UserDetails(
                    username: ref.watch(userDetailsProvider).username,
                    userType: ref.watch(userDetailsProvider).userType);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapScreen(),
                  ),
                );
              },
              child: const Text('Add User'),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}
