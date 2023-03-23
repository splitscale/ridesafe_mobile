import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shca_test/screens/emergency_contacts_screen.dart';
import 'package:shca_test/screens/map_search_screen.dart';
import 'package:shca_test/screens/summary_screen.dart';
import 'package:shca_test/components/google_maps.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shca_test/components/share_location_button.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shca_test/models/contacts_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double _lastX = 0.0;
  double _lastY = 0.0;
  double _lastZ = 0.0;
  double _currentTime = 0.0;
  double _lastTime = 0.0;
  double _sheetTop = 500.0; // initial position of the bottom sheet
  bool _showBottomSheet = false; // flag to show/hide the bottom sheet
  StreamSubscription<GyroscopeEvent>? _subscriptionGyro;
  StreamSubscription<UserAccelerometerEvent>? _subscriptionAcc;

  @override
  void initState() {
    super.initState();
    _subscriptionGyro = Stream.periodic(const Duration(seconds: 1))
        .asyncMap((_) => gyroscopeEvents.first)
        .listen((event) {
      setState(() {});
    });
    _subscriptionAcc = Stream.periodic(const Duration(milliseconds: 500))
        .asyncMap((_) => userAccelerometerEvents.first)
        .listen((event) {
      double x = event.x;
      double y = event.y;
      double z = event.z;

      // Calculate acceleration in three dimensions
      double acceleration = (pow(x, 2) +
              pow(y, 2) +
              pow(z, 2) -
              pow(_lastX, 2) -
              pow(_lastY, 2) -
              pow(_lastZ, 2))
          .toDouble();

      acceleration = acceleration.abs();

      // get speed
      _currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
      double dt = _currentTime - _lastTime;

      setState(() {
        _lastX = x;
        _lastY = y;
        _lastZ = z;
        _lastTime = _currentTime;
      });
    });
  }

  @override
  void dispose() {
    _subscriptionGyro?.cancel();
    _subscriptionAcc?.cancel();
    super.dispose();
  }

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              // width is less
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(100, 30),
              ),
              child: const Text('Emergency Contacts',
                  style: TextStyle(fontSize: 14.0)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmergencyContactsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 16.0),
            const ShareLiveLocationButton()
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SummaryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapSearchScreen(),
                    ),
                  );
                },
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              color: Colors.grey[300],
              width: double.infinity,
              // auto
              height: MediaQuery.of(context).size.width * 0.8,
              child: const Center(child: MapSample()),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailBox(context, 'Alcohol Level', '0.05'),
                _buildDetailBox(context, 'Ignition', 'On'),
                _buildDetailBox(context, 'Helmet', 'Correct'),
                _buildDetailBox(context, 'IoT', 'Connected'),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 200.0,
                  color: Colors.white,
                  child: Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          final contactsBox = Hive.box<Contact>('contacts');
                          final phoneNumbers = contactsBox.values
                              .map((contact) => contact.phone.toString())
                              .toList();
                          _sendSMS(
                              "Help me, I'm in an emergency!", phoneNumbers);
                        },
                        child: Text(
                          'Press for Emergency',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        // circular, red button
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(75))),
                  ),
                );
              },
            );
          },
          child: Icon(Icons.emergency),
          backgroundColor: Colors.redAccent),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDetailBox(BuildContext context, String title, String value) {
    return Container(
      width: MediaQuery.of(context).size.width / 4.5,
      height: MediaQuery.of(context).size.width / 3.5 * 1.5,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
