// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ridesafe_api/ridesafe.dart';
import 'package:shca_test/ridesafe_bluetooth/bluetooth_actions_handler.dart';
import 'package:shca_test/ridesafe_bluetooth/bluetooth_scanning_handler.dart';
import 'package:shca_test/widgets/stream_text.dart';

import '../../stream/console/console.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  _TerminalScreenState createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  late BluetoothScanningHandler _service;
  late BluetoothActionsHandler _actionsHandler;

  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late final Stream<String> _logStream;

  bool _isConnected = false;

  void _handleTextFieldSubmit(String str) {
    setState(() {
      _textEditingController.clear();
      _actionsHandler.send(_textEditingController.text);
    });
  }

  bool _checkConnection() {
    return _actionsHandler.isConnected;
  }

  void _handleClearConsole() {
    setState(() {
      Console.clear();
    });
  }

  Future<void> _handleConnection() async {
    try {
      final connectedDeviceController = await _service.scanAndConnect();

      _actionsHandler = BluetoothActionsHandler(connectedDeviceController);

      setState(() {
        _isConnected = _checkConnection();
        _actionsHandler.startListening();
      });
    } catch (e) {
      Console.error(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _service = BluetoothScanningHandler(Ridesafe.controller);

    _logStream = Console.logStream;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _actionsHandler.dispose();
    Console.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: kToolbarHeight, // Use the same height as AppBar
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      'HC-05 Terminal',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isConnected ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          color: _isConnected ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isConnected
                              ? Icons.bluetooth_connected // Use connected icon
                              : Icons
                                  .bluetooth_disabled, // Use disconnected icon
                          color: _isConnected ? Colors.blue : Colors.grey,
                        ),
                        onPressed: _handleConnection,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: _handleClearConsole,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamText(
                textStream: _logStream,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _textEditingController,
                    onSubmitted: (str) {
                      _handleTextFieldSubmit(str);
                      _focusNode.requestFocus();
                    },
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Type your command here',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _handleTextFieldSubmit(_textEditingController.text);
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
