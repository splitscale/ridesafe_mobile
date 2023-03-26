import 'package:flutter/material.dart';
import 'package:ridesafe_api/api_endpoints.dart';
import 'package:ridesafe_api/ridesafe_api.dart';
import 'package:shca_test/screens/terminal/terminal_screen.dart';
import 'package:shca_test/screens/landing_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shca_test/models/contacts_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'dependencies/flutter_dependency_initializer.dart';

void main() async {
  final dependencyInitializer = FlutterDependencyInitializer<Ridesafe>(
    [
      () async => ApiEndpoints(),
    ],
    () async => Ridesafe(ApiEndpoints()),
  );

  final Ridesafe ridesafe = await dependencyInitializer.initialize();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(ContactAdapter());
  await Hive.openBox<Contact>('contacts');

  runApp(ProviderScope(
      child: MyApp(
    ridesafe: ridesafe,
  )));
}

class MyApp extends StatelessWidget {
  final Ridesafe _ridesafe;

  const MyApp({Key? key, required Ridesafe ridesafe})
      : _ridesafe = ridesafe,
        super(key: key);

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
      home: RideSafeLandingScreen(),
    );
  }
}
