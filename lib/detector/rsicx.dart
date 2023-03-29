import 'package:ridesafe_engine/rsicx_engine.dart';

class Rsicx {
  static late RsicxEngine _engine;

  static Future<void> initialize() async {
    _engine = RsicxEngine(20, 30);
    await Future.delayed(const Duration(seconds: 1));
  }

  static RsicxEngine get detector {
    try {
      return _engine;
    } catch (e) {
      throw Exception('engine is not initialized');
    }
  }
}
