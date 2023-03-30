import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shca_test/screens/map_screen.dart';
import 'package:shca_test/components/add_user_button.dart';
import 'package:ridesafe_api/ridesafe_api.dart';

import 'package:shca_test/providers/username_provider.dart';
import 'package:shca_test/providers/json_provider.dart';

class UsernameScreen extends ConsumerWidget {
  final Ridesafe ridesafe;
  const UsernameScreen({Key? key, required this.ridesafe}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var userDetails = ref.watch(userDetailsProvider);
    var mockData = ref.watch(mockDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Selection'),
        backgroundColor: const Color.fromARGB(255, 2, 56, 110),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Card(
              color: Color.fromARGB(100, 95, 148, 200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                // side: BorderSide(
                //   color: Colors.grey.shade400,
                //   width: 1.0,
                // ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    const Text(
                      'Enter Username',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      onChanged: (value) {
                        ref.read(userDetailsProvider.notifier).state =
                            UserDetails(
                                username: value,
                                userType: userDetails.userType);
                      },
                      decoration: InputDecoration(
                        hintText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.0,
                          ),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    const Text(
                      'Choose Selection',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Radio<UserType>(
                          value: UserType.driver,
                          groupValue: ref.watch(userDetailsProvider).userType,
                          onChanged: (value) {
                            ref.read(userDetailsProvider.notifier).state =
                                UserDetails(
                                    username:
                                        ref.watch(userDetailsProvider).username,
                                    userType: value!);
                          },
                        ),
                        const Text('Driver',
                            style: TextStyle(
                              fontSize: 20,
                            )),
                        const SizedBox(width: 32),
                        Radio<UserType>(
                          value: UserType.family,
                          groupValue: ref.watch(userDetailsProvider).userType,
                          onChanged: (value) {
                            ref.read(userDetailsProvider.notifier).state =
                                UserDetails(
                                    username:
                                        ref.watch(userDetailsProvider).username,
                                    userType: value!);
                          },
                        ),
                        const Text('Family',
                            style: TextStyle(
                              fontSize: 20,
                            )),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
            AddUser(
              username: ref.watch(userDetailsProvider).username,
              userType: ref.watch(userDetailsProvider).userType,
              ridesafe: ridesafe,
            ),
          ],
        ),
      ),
    );
  }
}
