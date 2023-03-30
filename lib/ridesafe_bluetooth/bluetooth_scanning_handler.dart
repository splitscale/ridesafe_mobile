import 'package:ridesafe_api/api_endpoints.dart';
import 'package:ridesafe_api/device/connected_device_service_controller.dart';
import 'package:ridesafe_api/ridesafe_controller.dart';
import 'package:ridesafe_core/connected_device/connected_device.dart';
import 'package:ridesafe_core/device/device.dart';

import '../state/bool_state.dart';
import '../stream/console/console.dart';
import 'bluetooth_connection_handler.dart';

class BluetoothScanningHandler {
  final RidesafeController _controller;
  final BluetoothConnectionHandler _connHandler;

  BluetoothScanningHandler(RidesafeController ridesafeController)
      : _connHandler = BluetoothConnectionHandler(
          ridesafeController.bluetooth,
          ridesafeController.permissions,
          BoolState(),
          'HC-05',
          '1234',
        ),
        _controller = ridesafeController;

  Future<ConnectedDeviceServiceController> scanAndConnect() async {
    try {
      await _connHandler.assertDeviceBluetoothModule();
      await _connHandler.assertBluetoothPermission();
      final Device device = await _connHandler.scanDevices();

      final ConnectedDevice<BluetoothConnection> connectedDevice =
          await _connHandler.pairDevice(device);

      return _controller.getConnectedDeviceController(connectedDevice);
    } catch (e) {
      Console.error(e.toString());
      rethrow;
    }
  }
}
