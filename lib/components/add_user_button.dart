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
import 'package:ridesafe_api/ridesafe_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ridesafe_api/ridesafe_api.dart';
import 'package:shca_test/ridesafe_bluetooth/bluetooth_actions_handler.dart';
import 'package:shca_test/ridesafe_bluetooth/bluetooth_scanning_handler.dart';
import 'package:shca_test/widgets/stream_text.dart';
import 'package:shca_test/utils/bluetooth_parser.dart';

class AddUser extends StatefulWidget {
  final String username;
  final UserType userType;
  final Ridesafe ridesafe;

  AddUser(
      {Key? key,
      required this.username,
      required this.userType,
      required this.ridesafe})
      : super(key: key);

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  late BluetoothScanningHandler _service;
  late BluetoothActionsHandler _actionsHandler;

  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  JsonParser bluetoothData = JsonParser('{"a": 654, "b":0}');
  late final Stream<String> _logStream;

  bool _isConnected = false;

  void _handleTextFieldSubmit(String str) {
    setState(() {
      _textEditingController.clear();
      _actionsHandler.send(_textEditingController.text);
    });
  }

  bool _checkConnection() {
    return _actionsHandler.isConnected;
  }

  void _handleConnection() async {
    try {
      final connectedDeviceController = await _service.scanAndConnect();

      _actionsHandler = BluetoothActionsHandler(connectedDeviceController);

      setState(() {
        _isConnected = _checkConnection();
      });

      _actionsHandler.startListening().listen((event) {
        setState(() {
          bluetoothData = JsonParser(event);
          debugPrint(bluetoothData.toString());
        });
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _service = BluetoothScanningHandler(widget.ridesafe);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _actionsHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint the bluetooth data to the console
    return AddUserConsumer(
      username: widget.username,
      userType: widget.userType,
      ridesafe: widget.ridesafe,
      addBluetoothData: _handleConnection,
      bluetoothData: bluetoothData,
    );
  }
}

class AddUserConsumer extends ConsumerWidget {
  final String username;
  final UserType userType;
  final Ridesafe ridesafe;
  final JsonParser bluetoothData;
  void Function() addBluetoothData;
  AddUserConsumer({
    Key? key,
    required this.username,
    required this.userType,
    required this.ridesafe,
    required this.addBluetoothData,
    required this.bluetoothData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = FirebaseFirestore.instance.collection('users');
    Future<void> addUser() async {
      Position position = await Geolocator.getCurrentPosition();
      double latitude = position.latitude;
      double longitude = position.longitude;
      return users
          .doc(username)
          .set({
            'username': username,
            'userType': userType.toString(),
            'familyCode': sha1.convert(utf8.encode(username)).toString(),
            'latitude': latitude,
            'longitude': longitude,
          })
          .then((value) => debugPrint("User Added"))
          .catchError((error) => debugPrint("Failed to add user: $error"));
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
          addBluetoothData();
          addUser();
          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ref.watch(userDetailsProvider.notifier).state.userType ==
                              UserType.driver
                          ? MapScreen(bluetoothData: bluetoothData)
                          : const FamilyOptionScreen()));
        },
      ),
    );
  }
}
