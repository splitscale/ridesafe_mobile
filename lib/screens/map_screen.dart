import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shca_test/screens/emergency_contacts_screen.dart';
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
import 'package:shca_test/utils/bluetooth_parser.dart';
import 'package:shca_test/providers/bluetooth_provider.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../detector/rsicx_debug.dart';

class DetailCards extends ConsumerWidget {
  final String title;
  final String value;

  const DetailCards({Key? key, required this.title, required this.value})
      : super(key: key);

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
    var icon = _getIconForTitle(title);
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

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
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
    ref.read(bluetoothDataProvider);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _initSpeedDetection();

    // debug detectors
    debugRsicx();
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

  @override
  Widget build(BuildContext context) {
    bool inMotion = _speed >= 2.0;
    bool showAnimation = _speed >= 5.0;
    var bluetoothData = ref.watch(bluetoothDataProvider.notifier).state;

    var alcoholLevel = bluetoothData.a.toString();
    int helmetValue = bluetoothData.b;
    String helmetStatus = helmetValue == 0 ? 'Worn' : 'Not Worn';
    String ignitionStatus = helmetValue == 0 ? 'On' : 'Off';
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
                    style: TextStyle(fontSize: 12.0)),
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
                children: [
                  DetailCards(title: 'Alcohol Level', value: alcoholLevel),
                  DetailCards(title: 'Ignition Status', value: ignitionStatus),
                  DetailCards(title: 'Helmet Status', value: helmetStatus),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: const MyFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}

class MyFloatingActionButton extends StatefulWidget {
  const MyFloatingActionButton({Key? key}) : super(key: key);

  @override
  _MyFloatingActionButtonState createState() => _MyFloatingActionButtonState();
}

class _MyFloatingActionButtonState extends State<MyFloatingActionButton> {
  bool _showButtons = false;

  void _toggleButtons() {
    setState(() {
      _showButtons = !_showButtons;
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: _showButtons ? 120 : 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
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
                                final contactsBox =
                                    Hive.box<Contact>('contacts');
                                final phoneNumbers = contactsBox.values
                                    .map((contact) => contact.phone.toString())
                                    .toList();
                                _sendSMS("Help me, I'm in an emergency!",
                                    phoneNumbers);
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
                heroTag: 'Button 1',
                child: const Icon(Icons.emergency),
                backgroundColor: Colors.redAccent,
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return EmergencyListenerModal();
                    },
                  );
                },
                heroTag: 'Button 2',
                child: const Icon(Icons.radar),
                backgroundColor: Colors.red,
              ),
            ],
          ),
        ),
        FloatingActionButton(
          onPressed: _toggleButtons,
          backgroundColor: const Color.fromARGB(255, 2, 56, 110),
          child:
              _showButtons ? const Icon(Icons.close) : const Icon(Icons.menu),
        ),
      ],
    );
  }
}

class EmergencyListenerModal extends StatefulWidget {
  @override
  _EmergencyListenerModalState createState() => _EmergencyListenerModalState();
}

class _EmergencyListenerModalState extends State<EmergencyListenerModal> {
  bool _isListening = false;
  late StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _isShaking = false;
  bool _playSound = false;

  @override
  void dispose() {
    super.dispose();
    _stopAccelerometer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 16),
          const Text(
            "Automatic Emergency Listener",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (_isListening) {
                _stopAccelerometer();
              } else {
                _startAccelerometer();
              }
              setState(() {
                _isListening = !_isListening;
              });
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? Colors.red : Colors.green,
              ),
              child: Center(
                child: Text(
                  _isListening
                      ? "Listening for Accidents..."
                      : "Press to Listen",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _startAccelerometer() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.x.abs() > 15 || event.y.abs() > 15 || event.z.abs() > 15) {
        if (!_isShaking) {
          setState(() {
            _isShaking = true;
          });
          _playSound = true;
        }
      } else {
        if (_isShaking) {
          FlutterRingtonePlayer.play(fromAsset: "assets/alarm.mp3");

          setState(() {
            _isShaking = false;
          });
        }
      }
    });
  }

  void _stopAccelerometer() {
    if (_accelerometerSubscription != null) {
      _accelerometerSubscription!.cancel();
      _accelerometerSubscription = null;
    }
    setState(() {
      _isListening = false;
      _isShaking = false;
    });
    _playSound = false;
  }
}
