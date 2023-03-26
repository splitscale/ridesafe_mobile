import 'package:flutter/material.dart';
import 'package:shca_test/screens/emergency_contacts_screen.dart';
import 'package:shca_test/screens/map_search_screen.dart';
import 'package:shca_test/screens/summary_screen.dart';
import 'package:shca_test/components/google_maps.dart';
import 'package:shca_test/components/share_location_button.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shca_test/models/contacts_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shca_test/providers/json_provider.dart';

class DetailCards extends ConsumerWidget {
  final String title;

  const DetailCards({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var mockData = ref.watch(mockDataProvider);
    late String value;
    // Alcoho Level, Ignition, Helmet, IoT
    if (title == 'Alcohol Level') {
      value = mockData['helmet']['alcohol_level'].toString();
    } else if (title == 'Ignition') {
      value = mockData['motor']['is_ignition_ready'].toString();
    } else if (title == 'Helmet') {
      value = mockData['helmet']['is_worn'].toString();
    } else if (title == 'IoT') {
      value = mockData['gps']['latitude'].toString();
    }
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
              // child: TextField(
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => MapSearchScreen(),
              //       ),
              //     );
              //   },
              //   decoration: const InputDecoration(
              //     hintText: 'Search',
              //     prefixIcon: Icon(Icons.search),
              //     border: OutlineInputBorder(),
              //   ),
              // ),
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
                DetailCards(title: 'Alcohol Level'),
                DetailCards(title: 'Ignition'),
                DetailCards(title: 'Helmet'),
                DetailCards(title: 'IoT'),
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
