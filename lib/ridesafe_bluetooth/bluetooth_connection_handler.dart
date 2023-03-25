import 'package:flutter/cupertino.dart';
import 'package:ridesafe_api/api_endpoints.dart';
import 'package:ridesafe_api/device/device_service_controller.dart';
import 'package:ridesafe_api/permission/permission_service_controller.dart';
import 'package:ridesafe_core/connected_device/connected_device.dart';
import 'package:ridesafe_core/device/device.dart';
import 'package:ridesafe_core/exceptions/service_exception.dart';
import 'package:shca_test/state/bool_state.dart';
import 'package:shca_test/stream/console/console.dart';

class BluetoothConnectionHandler {
  final String _targetDeviceName;
  final String _targetDevicePin;
  final PermissionServiceController _permissionService;
  final DeviceServiceController<Future<BluetoothState>, BluetoothConnection>
      _bluetoothService;
  final BoolState _scanState;

  BluetoothConnectionHandler(
    this._bluetoothService,
    this._permissionService,
    this._scanState,
    this._targetDeviceName,
    this._targetDevicePin,
  );

  void _logErr(String msg) {
    debugPrint(msg);
    Console.error(msg);
  }

  void _logStep(String msg) {
    debugPrint(msg);
    Console.info(msg);
  }

  // s0
  // check if has permission already
  //    if true: return
  // ask for permission
  // if done
  //    return
  //    goto s1
  // if fail throw exception
  Future<void> assertBluetoothPermission() async {
    try {
      final bluetoothPermission = await _permissionService.status;
      final isDenied = bluetoothPermission.isDenied;
      final isGranted = bluetoothPermission.isGranted;

      _logStep(isDenied.toString());
      _logStep(isGranted.toString());

      if (isDenied) {
        await _permissionService.request();
      }

      if (isDenied) {
        await _bluetoothService.openInternalSettings();
      }

      if (isGranted) {
        _logStep('BluetoothPermission granted');
      }
    } catch (e) {
      _logErr('[assertBluetoothPermissionErr]: ${e.toString()}');
    }
  }

  // s1
  // assert if device has bluetooth module
  // returns bool
  Future<void> assertDeviceBluetoothModule() async {
    try {
      final isAvailable = await _bluetoothService.isServiceAvailable() &&
          await _bluetoothService.isServiceEnabled();

      if (!isAvailable) {
        throw ServiceException('Device Bluetooth Module NOT available');
      }

      _logStep('Device Bluetooth Module IS available');
    } catch (e) {
      _logErr(e.toString());
    }
  }

  // s2
  // handle both local and public scans
  // try s3
  //      get Device object
  //      return [Device] object
  //    catch
  //      log error
  //
  // try s4
  //      get Device object
  //      disable scan state
  //        return [Device] object
  //    catch
  //      log error
  //      throw error "not found"
  Future<Device> scanDevices() async {
    try {
      _scanState.enable();
      final device = await scanPairedDevices();

      return device;
    } catch (e) {
      _logErr(e.toString());
    } finally {
      _scanState.disable();
    }

    try {
      _scanState.enable();
      final device = await scanPublicDevices();

      return device;
    } catch (e) {
      _logErr(e.toString());
      throw ServiceException('No public Device found: $e');
    } finally {
      _scanState.disable();
    }
  }

  // s3
  // scan paired devices
  // if device.name is hc-05:
  //  true - return [Device] object
  //  false - throw exception
  Future<Device> scanPairedDevices() async {
    final devices = await _bluetoothService.getPairedDevices();
    final pairedDevice = devices
        .where(
          (device) => device.name == _targetDeviceName,
        )
        .toList();

    if (pairedDevice.isNotEmpty) {
      return pairedDevice.first;
    } else {
      throw ServiceException('No paired device found');
    }
  }

  // s4
  // scan public devices
  // if device.name is hc-05:
  //  true - return [Device] object
  //  false - throw exception
  Future<Device> scanPublicDevices() async {
    try {
      final Stream<Device> publicDeviceStream =
          _bluetoothService.startScanning();

      await for (final device in publicDeviceStream) {
        _logStep(
          'Found: ${device.name.isEmpty ? device.address : device.name}',
        );

        if (device.name == _targetDeviceName) {
          return device;
        }
      }

      throw ServiceException('Scan finished without finding the device');
    } catch (e) {
      _logErr(e.toString());
      throw ServiceException('Device not found: $e');
    } finally {
      _logStep('Stopping scanner');
      await _bluetoothService.stopScanning();
    }
  }

  // s5
// handle connecting to paired device
// returns [ConnectedDevice] object
// throw exception
  Future<ConnectedDevice<BluetoothConnection>> connectToPairedDevice(
      Device device) async {
    _logStep('connecting to paired device: ${device.name}');
    try {
      final connectedDevice = await _bluetoothService.connect(device);
      _logStep('connected to device: ${connectedDevice.name}');
      return connectedDevice;
    } catch (e) {
      _logErr(e.toString());
      throw ServiceException('Failed to connect to device: $e');
    }
  }

// s6
// handle pairing of public device
// return [ConnectedDevice] object
// throw exception
  Future<ConnectedDevice<BluetoothConnection>> pairDevice(Device device) async {
    try {
      if (!device.isPaired) {
        _logStep('pairing to: ${device.name}');
        await _bluetoothService.pair(device, _targetDevicePin);
      }

      return (await connectToPairedDevice(device));
    } catch (e) {
      _logErr(e.toString());
      throw ServiceException('Failed to pair or connect to device: $e');
    }
  }
}
