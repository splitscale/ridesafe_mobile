import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FamilyMapViewScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String name;

  const FamilyMapViewScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LatLng initialPosition = LatLng(latitude, longitude);
    final CameraPosition initialCameraPosition =
        CameraPosition(target: initialPosition, zoom: 15.0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 2, 56, 110),
        title: Text('Family Map'),
      ),
      body: Column(
        children: [
          SizedBox(height: 32.0),
          Text(
            'Live Location',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Location available',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 32.0),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: initialCameraPosition,
              markers: {
                Marker(
                  markerId: MarkerId('person'),
                  position: initialPosition,
                  infoWindow: InfoWindow(title: name),
                ),
              },
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
