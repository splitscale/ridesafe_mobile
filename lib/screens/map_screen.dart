import 'package:flutter/material.dart';
import 'package:shca_test/screens/emergency_contacts_screen.dart';
import 'package:shca_test/screens/map_search_screen.dart';
import 'package:shca_test/components/motor_container.dart';
import 'package:shca_test/screens/summary_screen.dart';
import 'package:shca_test/components/google_maps.dart';
import 'package:shca_test/components/share_location_button.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shca_test/models/contacts_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shca_test/providers/json_provider.dart';
import 'package:geolocator/geolocator.dart';

class DetailCards extends ConsumerWidget {
  final String title;

  const DetailCards({Key? key, required this.title}) : super(key: key);

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Alcohol Level':
        return Icons.local_bar;
      case 'Ignition Status':
        return Icons.power_settings_new;
      case 'Helmet Status':
        return Icons.motorcycle_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var mockData = ref.watch(mockDataProvider);
    String value = '10';
    var icon = _getIconForTitle(title);
    if (title == 'Alcohol Level') {
      value = '87';
    } else if (title == 'Ignition Status') {
      value = 'On';
    } else if (title == 'Helmet Status') {
      value = 'Worn';
    }

    // Alcoho Level, Ignition, Helmet, IoT
    // try {
    //   if (title == 'Alcohol Level') {
    //     value = mockData['helmet']['alcohol_level'].toString();
    //   } else if (title == 'Ignition') {
    //     value = mockData['motor']['is_ignition_ready'].toString();
    //   } else if (title == 'Helmet') {
    //     value = mockData['helmet']['is_worn'].toString();
    //   } else if (title == 'IoT') {
    //     value = mockData['gps']['latitude'].toString();
    //   }
    // } catch (e) {
    //   return const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }
    return Container(
      width: MediaQuery.of(context).size.width / 3.5,
      height: MediaQuery.of(context).size.width / 3.5 * 1.75,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32.0,
            color: Colors.blue,
          ),
          const SizedBox(height: 16.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            value ?? 'N/A',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  double _lastX = 0.0;
  double _lastY = 0.0;
  double _lastZ = 0.0;
  double _currentTime = 0.0;
  double _lastTime = 0.0;
  double _sheetTop = 500.0; // initial position of the bottom sheet
  bool _showBottomSheet = false; // flag to show/hide the bottom sheet
  AnimationController? _animationController;
  double _speed = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _initSpeedDetection();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  Future<void> _initSpeedDetection() async {
    Geolocator.getPositionStream().listen((Position position) {
      double speed = position.speed ?? 0.0;
      if (speed < 0) {
        speed = 0;
      }
      setState(() {
        _speed = speed * 3.6;
      });
    });
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
    bool inMotion = _speed >= 2.0;
    bool showAnimation = _speed >= 5.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 2, 56, 110),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              // width is less
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(100, 30),
                backgroundColor: Color.fromARGB(255, 48, 152, 255),
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
              child: MotorcycleContainer(
                animationController: _animationController,
                speed: _speed,
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
              children: const [
                DetailCards(title: 'Alcohol Level'),
                DetailCards(title: 'Ignition Status'),
                DetailCards(title: 'Helmet Status'),
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
}
