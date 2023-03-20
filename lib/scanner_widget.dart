import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shca_test/bluetooth_scanner.dart';

class ScannerWidget extends StatefulWidget {
  const ScannerWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ScannerWidget();
  }
}

class _ScannerWidget extends State<ScannerWidget> {
  final BluetoothScanner _bleScanner = BluetoothScanner();
  List<ScanResult> _devices = [];

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    _bleScanner.startScan();
  }

  void _stopScan() {
    _bleScanner.stopScan();
  }

  void _getDevices() async {
    List<ScanResult> devices = await _bleScanner.getDevices();
    setState(() {
      _devices = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _startScan,
              child: const Text('Start Scan'),
            ),
            ElevatedButton(
              onPressed: _stopScan,
              child: const Text('Stop Scan'),
            ),
            ElevatedButton(
              onPressed: _getDevices,
              child: const Text('Get Devices'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  ScanResult device = _devices[index];
                  return ListTile(
                    title: Text(device.device.name),
                    subtitle: Text(device.device.id.toString()),
                    trailing: Text('${device.rssi}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
