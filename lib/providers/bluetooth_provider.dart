import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shca_test/utils/bluetooth_parser.dart';

class BluetoothDataProvider extends StateNotifier<JsonParser> {
  BluetoothDataProvider() : super(JsonParser('{"a": 142, "b":0}'));

  void update(JsonParser newData) {
    state = newData;
  }
}

final bluetoothDataProvider =
    StateNotifierProvider((ref) => BluetoothDataProvider());
