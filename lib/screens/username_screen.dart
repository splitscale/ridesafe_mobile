import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shca_test/providers/username_provider.dart';
import 'package:shca_test/components/add_user_button.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bluetoothProvider = ChangeNotifierProvider<BluetoothController>((ref) {
  final controller = BluetoothController();
  controller.getBondedDevices();
  return controller;
});

class BluetoothController extends ChangeNotifier {
  List<BluetoothDevice> _devices = [];
  late BluetoothDevice _selectedDevice;
  late BluetoothConnection _connection;
  String _receivedData = '';

  List<BluetoothDevice> get devices => _devices;
  BluetoothDevice get selectedDevice => _selectedDevice;
  BluetoothConnection get connection => _connection;
  String get receivedData => _receivedData;

  Future<void> getBondedDevices() async {
    _devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    notifyListeners();
  }

  Future<void> connectToDevice() async {
    try {
      _connection =
          await BluetoothConnection.toAddress(_selectedDevice.address!);
      _connection.input?.listen(_onDataReceived).onDone(() {
        notifyListeners();
      });
    } catch (error) {
      print('ERROR: $error');
    }
    notifyListeners();
  }

  void _onDataReceived(Uint8List data) {
    _receivedData += utf8.decode(data);
    notifyListeners();
  }

  void disconnect() {
    _connection.dispose();
    notifyListeners();
  }

  void setSelectedDevice(BluetoothDevice device) {
    _selectedDevice = device;
    notifyListeners();
  }
}

class UsernameScreen extends ConsumerWidget {
  const UsernameScreen({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(bluetoothProvider);
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
            ElevatedButton(
              child: Text('Select Device'),
              onPressed: () async {
                List<BluetoothDevice> devices = controller.devices;
                BluetoothDevice? selected = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Select Bluetooth Device'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: devices
                              .map((device) => ListTile(
                                    title: Text(device.name.toString()),
                                    subtitle: Text(device.address),
                                    onTap: () {
                                      controller.setSelectedDevice(device);
                                      Navigator.of(context).pop(device);
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                    );
                  },
                );
                if (selected != null) {
                  controller.setSelectedDevice(selected);
                }
              },
            ),
            ElevatedButton(
              child: Text('Connect'),
              onPressed: () {
                controller.connectToDevice();
              },
            ),
            ElevatedButton(
              child: Text('Disconnect'),
              onPressed: () {
                controller.disconnect();
              },
            ),
            Text(controller.receivedData),
            Expanded(child: Container()),
            AddUser(
              username: ref.watch(userDetailsProvider).username,
              userType: ref.watch(userDetailsProvider).userType,
            ),
          ],
        ),
      ),
    );
  }
}
