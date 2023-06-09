import 'package:flutter/foundation.dart';
import 'package:ridesafe_api/api_endpoints.dart';
import 'package:ridesafe_api/device/connected_device_service_controller.dart';
import 'package:ridesafe_core/connected_device/connected_device.dart';
import 'package:shca_test/stream/console/console.dart';

class BluetoothActionsHandler {
  final ConnectedDeviceServiceController _controller;

  BluetoothActionsHandler(ConnectedDeviceServiceController controller)
      : _controller = controller;

  Stream<String> startListening() {
    final stream = _controller.startListening();

    return stream.map((event) {
      debugPrint(event);
      Console.log(event);
      return event.toString();
    });
  }

  Future<void> send(String message) async {
    try {
      await _controller.send(message);
    } catch (e) {
      Console.error(e.toString());
    }
  }

  Future<void> disconnect() async {
    try {
      await _controller.disconnect();
    } catch (e) {
      Console.error(e.toString());
    }
  }

  Future<void> dispose() async {
    try {
      await _controller.stopListening();
    } catch (e) {
      Console.error(e.toString());
    }
  }

  bool get isConnected => _controller.isConnected;
}
