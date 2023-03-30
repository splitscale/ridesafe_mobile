import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:ridesafe_engine/rsicx.dart';
import 'package:sensors_plus/sensors_plus.dart';

void debugRsicx() {
  final distanceTrigger = Rsicx.detector.distanceTrigger;

  // userAccelerometerEvents.listen((UserAccelerometerEvent event) {
  //   print(event);
  // });

  calculateSpeed();

  // Geolocator.getPositionStream().listen((position) {
  //   final speedMps = position.speed;
  //   final time = position.timestamp?.toString();

  //   if (position.timestamp != null) {
  //     distanceTrigger.trackDistance(position.timestamp!, position.speed);
  //   } else {
  //     print('distance not triggered');
  //   }

  //   print('speed: ${getTwoDecimalPlaces(speedMps)}');
  //   print('seconds: $time');
  // });
}

int getTwoDecimalPlaces(double number) {
  return (number * 100).toInt() ~/ 10;
}

calculateSpeed() {
  double speed = 0;
  double distance = 0;
  DateTime lastTime = DateTime.now();
  double gravity = 9.81; // acceleration due to gravity in m/s^2

  userAccelerometerEvents.listen((UserAccelerometerEvent event) {
    DateTime now = DateTime.now();
    double timeInSeconds = now.difference(lastTime).inMilliseconds / 1000.0;
    lastTime = now;

    // Subtract acceleration due to gravity from the acceleration
    double acceleration =
        sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2)) - gravity;

    // Check if the acceleration is less than zero, which means it's in the opposite direction of motion
    if (acceleration < 0) {
      acceleration = 0;
    }

    distance += 0.5 * acceleration * pow(timeInSeconds, 2);

    speed = distance / (now.millisecondsSinceEpoch / 1000.0);
  });
}
