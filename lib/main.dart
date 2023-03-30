import 'package:flutter/material.dart';
import 'package:ridesafe_api/ridesafe.dart';
import 'package:ridesafe_engine/rsicx.dart';
import 'package:shca_test/screens/landing_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shca_test/models/contacts_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init api
  await Ridesafe.initialize();

  // init detector engine
  await Rsicx.initialize(triggerDistance: 20, shockThreshold: 30);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(ContactAdapter());
  await Hive.openBox<Contact>('contacts');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      // home: TerminalScreen(ridesafe: _ridesafe),
      home: const RideSafeLandingScreen(),
    );
  }
}
