import 'package:ridesafe_api/ridesafe_api.dart';
import 'package:ridesafe_core/device/device.dart';
import 'package:shca_test/ridesafe_bluetooth/bluetooth_connection_handler.dart';
import 'package:shca_test/state/bool_state.dart';
import 'package:shca_test/stream/console/console.dart';

class BluetoothTestController {
  final BluetoothConnectionHandler _connHandler;

  BluetoothTestController()
      : _connHandler = BluetoothConnectionHandler(
          Ridesafe.bluetooth,
          Ridesafe.permissions,
          BoolState(),
          'HC-05',
          '1234',
        );

  Future<void> testControllers() async {
    try {
      await _connHandler.assertBluetoothPermission();
      await _connHandler.assertDeviceBluetoothModule();
      final Device device = await _connHandler.scanDevices();

      if (device.isPaired) {
        final connectedDevice =
            await _connHandler.connectToPairedDevice(device);

        final connectedDeviceController =
            Ridesafe.getConnectedDeviceController(connectedDevice);

        final stream = connectedDeviceController.startListening();

        stream.listen((event) {
          Console.log(event);
        });
      }
    } catch (e) {
      Console.error(e.toString());
    }
  }
}
