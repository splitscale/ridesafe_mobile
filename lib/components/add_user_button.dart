// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridesafe_api/ridesafe.dart';
import 'package:shca_test/providers/username_provider.dart';
import 'package:shca_test/screens/family_share_screen.dart';
import 'package:shca_test/screens/map_screen.dart';
import 'package:crypto/crypto.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shca_test/ridesafe_bluetooth/bluetooth_actions_handler.dart';
import 'package:shca_test/ridesafe_bluetooth/bluetooth_scanning_handler.dart';
import 'package:shca_test/utils/bluetooth_parser.dart';
import 'package:shca_test/providers/bluetooth_provider.dart';

class AddUser extends ConsumerStatefulWidget {
  final String username;
  final UserType userType;

  const AddUser({Key? key, required this.username, required this.userType})
      : super(key: key);

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends ConsumerState<AddUser> {
  late BluetoothScanningHandler _service;
  late BluetoothActionsHandler _actionsHandler;

  final TextEditingController _textEditingController = TextEditingController();

  late final BluetoothDataProvider _bluetoothDataProvider;

  void _handleConnection() async {
    try {
      final connectedDeviceController = await _service.scanAndConnect();

      _actionsHandler = BluetoothActionsHandler(connectedDeviceController);

      _actionsHandler.startListening().listen((event) {
        final newBluetoothData = JsonParser(event);
        debugPrint(newBluetoothData.toString());
        // Update the BluetoothDataProvider state with newBluetoothData
        _bluetoothDataProvider.update(newBluetoothData);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _service = BluetoothScanningHandler(Ridesafe.controller);
    ref.read(bluetoothDataProvider);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _actionsHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = FirebaseFirestore.instance.collection('users');
    final bluetoothData = ref.watch(bluetoothDataProvider.notifier).state;

    Future<void> addUser() async {
      Position position = await Geolocator.getCurrentPosition();
      double latitude = position.latitude;
      double longitude = position.longitude;
      return users
          .doc(widget.username)
          .set({
            'username': widget.username,
            'userType': widget.userType.toString(),
            'familyCode': sha1.convert(utf8.encode(widget.username)).toString(),
            'latitude': latitude,
            'longitude': longitude,
          })
          .then((value) => debugPrint("User Added"))
          .catchError((error) => debugPrint("Failed to add user: $error"));
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF0270B8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () async {
          ref.read(userDetailsProvider.notifier).state = UserDetails(
              username: ref.watch(userDetailsProvider).username,
              userType: ref.watch(userDetailsProvider).userType);

          addUser();

          // try {
          //   final connectedDeviceController = await _service.scanAndConnect();

          //   _actionsHandler =
          //       BluetoothActionsHandler(connectedDeviceController);

          //   // use timer.periodic to send data every 5 seconds
          //   Timer.periodic(const Duration(seconds: 2), (timer) {
          //     _actionsHandler.startListening().listen((event) {
          //       final newBluetoothData = JsonParser(event);
          //       // Update the BluetoothDataProvider state with newBluetoothData
          //       _bluetoothDataProvider.update(newBluetoothData);
          //     });
          //   });
          // } catch (e) {
          //   debugPrint(e.toString());
          // }

          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ref.watch(userDetailsProvider.notifier).state.userType ==
                              UserType.driver
                          ? const MapScreen()
                          : const FamilyOptionScreen()));
        },
        child: const Text('Connect'),
      ),
    );
  }
}
