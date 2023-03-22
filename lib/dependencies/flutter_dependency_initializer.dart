import 'package:flutter/widgets.dart';

class FlutterDependencyInitializer<T> {
  final List<Future<dynamic> Function()> _dependencies;
  final Future<T> Function() _initializer;

  FlutterDependencyInitializer(this._dependencies, this._initializer);

  Future<T> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Future.wait(_dependencies.map((dep) => dep()));

    return _initializer();
  }
}
