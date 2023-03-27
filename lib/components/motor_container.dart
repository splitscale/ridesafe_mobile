import 'package:flutter/material.dart';

class MotorcycleContainer extends StatelessWidget {
  double speed;
  AnimationController? animationController;
  MotorcycleContainer({
    Key? key,
    required this.speed,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool inMotion = speed >= 2.0;
    bool showAnimation = speed >= 5.0;
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 2, 56, 110),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.motorcycle,
                color: inMotion
                    ? Colors.red
                    : const Color.fromARGB(255, 2, 56, 110),
              ),
              SizedBox(width: 8.0),
              Text(
                inMotion ? 'You are in motion!' : 'You are not in motion!',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          Text(
            '(${speed.toStringAsFixed(0)} km/h)',
            style: TextStyle(
              fontSize: 16.0,
              color: inMotion ? Colors.black : Colors.grey,
            ),
          ),
          if (showAnimation)
            AnimatedBuilder(
              animation: animationController!,
              builder: (_, child) => Transform.rotate(
                angle: animationController!.value * 6.3,
                child: child!,
              ),
              child: Icon(
                Icons.trip_origin,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}
