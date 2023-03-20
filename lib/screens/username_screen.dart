import 'package:flutter/material.dart';
import 'package:shca_test/screens/user_type_screen.dart';

class UsernameScreen extends StatelessWidget {
  final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect to helmet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 250,
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        hintText: 'username',
                      ),
                    ),
                  )),
            ),
            ElevatedButton(
              child: const Text('Connect'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserTypeSelectionScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
