import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:shca_test/models/contacts_model.dart';

class EditEmergencyContactScreen extends StatefulWidget {
  final Contact contact;

  const EditEmergencyContactScreen({Key? key, required this.contact})
      : super(key: key);

  @override
  EditEmergencyContactScreenState createState() =>
      EditEmergencyContactScreenState();
}

class EditEmergencyContactScreenState
    extends State<EditEmergencyContactScreen> {
  late String name;
  late String phoneNumber;

  @override
  void initState() {
    super.initState();
    name = widget.contact.name;
    phoneNumber = widget.contact.phone;
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
        backgroundColor: const Color.fromARGB(255, 2, 56, 110),
        title: Text(widget.contact == null
            ? 'Add Emergency Contact'
            : 'Edit Emergency Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Name',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              onChanged: (value) {
                name = value;
              },
              decoration: InputDecoration(
                hintText: 'Enter name',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: name),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Phone',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              onChanged: (value) {
                phoneNumber = value;
              },
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Enter phone number',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: phoneNumber),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 56, 110),
                ),
                onPressed: () async {
                  final contactBox = await Hive.openBox<Contact>('contacts');
                  if (widget.contact == null) {
                    final newContact = Contact(name, phoneNumber);
                    await contactBox.add(newContact);
                  } else {
                    widget.contact.name = name;
                    widget.contact.phone = phoneNumber;
                    await contactBox.put(widget.contact.key, widget.contact);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
