import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothScanner {
  FlutterBluePlus service = FlutterBluePlus.instance;

  // Start scanning for nearby BLE devices
  Future<void> startScan() async {
    // Start scanning
    service.startScan(timeout: const Duration(seconds: 4));

    // Listen to scan results
    service.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        debugPrint(
            '${r.device.name} found! di: ${r.device.id} rssi: ${r.rssi}');
      }
    });
  }

  // Stop scanning for BLE devices
  void stopScan() {
    service.stopScan();
  }

  // Get a list of nearby BLE devices and display their information
  Future<List<ScanResult>> getDevices() async {
    List<ScanResult> devices = [];

    // Listen to scan results
    service.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult result in results) {
        devices.add(result);
        debugPrint(
            '${result.device.name} (${result.device.id}) RSSI: ${result.rssi}');
      }
    });

    await service.stopScan();
    return devices;
  }
}
