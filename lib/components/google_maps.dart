// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';

// class MapSample extends StatefulWidget {
//   const MapSample({Key? key}) : super(key: key);

//   @override
//   State<MapSample> createState() => MapSampleState();
// }

// class MapSampleState extends State<MapSample> {
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();

//   LatLng? _center;

//   StreamSubscription<Position>? _positionStreamSubscription;

//   Set<Marker> _markers = {};

//   void _addMarkers() {
//     // add current location
//     _markers.add(Marker(
//       markerId: const MarkerId('current'),
//       position: _center!,
//       infoWindow: const InfoWindow(title: 'Current Location'),
//     ));
//     _markers.add(Marker(
//       markerId: const MarkerId('wvmc'),
//       position: const LatLng(10.697478, 122.554337),
//       infoWindow: const InfoWindow(title: 'Western Visayas Medical Center'),
//     ));
//     _markers.add(Marker(
//       markerId: const MarkerId('csmc'),
//       position: const LatLng(10.695792, 122.561736),
//       infoWindow: const InfoWindow(title: 'CPU Medical Center'),
//     ));
//     // Add more markers for other emergency centers here
//   }

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _positionStreamSubscription?.cancel();
//   }

//   void _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }

//     _positionStreamSubscription =
//         Geolocator.getPositionStream().listen((Position position) {
//       setState(() {
//         _center = LatLng(position.latitude, position.longitude);
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     _addMarkers();
//     return _center == null
//         ? const Center(child: CircularProgressIndicator())
//         : GoogleMap(
//             mapType: MapType.hybrid,
//             initialCameraPosition: CameraPosition(target: _center!, zoom: 14.0),
//             onMapCreated: (GoogleMapController controller) {
//               _controller.complete(controller);
//             },
//             markers: _markers,
//           );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Location {
  final String name;
  final LatLng latLng;
  final String phone;
  final String imageUrl;
  final LocationType type;

  Location({
    required this.name,
    required this.latLng,
    required this.phone,
    required this.imageUrl,
    required this.type,
  });
}

enum LocationType {
  Hospital,
  PoliceStation,
  FireStation,
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  LatLng? _center;

  StreamSubscription<Position>? _positionStreamSubscription;

  Set<Marker> _markers = {};

  List<Location> _locations = [
    Location(
      name: 'Western Visayas Medical Center',
      latLng: const LatLng(10.7043, 122.5473),
      phone: '033 321 1243',
      imageUrl:
          'https://lh5.googleusercontent.com/p/AF1QipPjRlNn8ZvNlV7wTmEM1aKy7r8cTavTj7sQF9m9=w408-h306-k-no',
      type: LocationType.Hospital,
    ),
    Location(
      name: 'Iloilo Mission Hospital',
      latLng: const LatLng(10.6984, 122.5642),
      phone: '033 335 0888',
      imageUrl:
          'https://lh5.googleusercontent.com/p/AF1QipOw-lMJbVREcFcdlWfJdGyL6g-bB7jQ-KmFbY8z=w408-h408-k-no',
      type: LocationType.Hospital,
    ),
    Location(
      name: 'Mandurriao Police Station',
      latLng: const LatLng(10.7120, 122.5472),
      phone: '033 321 3594',
      imageUrl:
          'https://lh5.googleusercontent.com/p/AF1QipN2Fgzmp9R4sh4PH4fB8YRhZwbuTRJddGv2LsAS=w408-h306-k-no',
      type: LocationType.PoliceStation,
    ),
    Location(
      name: 'La Paz Fire Station',
      latLng: const LatLng(10.6937, 122.5591),
      phone: '033 320 0322',
      imageUrl:
          'https://lh5.googleusercontent.com/p/AF1QipN5St7OZ_1HSpVLxvyjKv88d-znWfDIiw0JvpX9=w408-h306-k-no',
      type: LocationType.FireStation,
    ),
  ];

  BitmapDescriptor _hospitalMarker = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueRed,
  );
  BitmapDescriptor _policeStationMarker = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueBlue,
  );
  BitmapDescriptor _fireStationMarker = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueOrange,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
    _positionStreamSubscription?.cancel();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
      });
    });
  }

  void _addMarkers() {
    _markers = _locations.map((location) {
      return Marker(
        markerId: MarkerId(location.name),
        position: location.latLng,
        infoWindow: InfoWindow(
          title: location.name,
          snippet: location.phone,
        ),
        icon: _getMarkerIcon(location.type),
      );
    }).toSet();
  }

  BitmapDescriptor _getMarkerIcon(LocationType type) {
    switch (type) {
      case LocationType.Hospital:
        return _hospitalMarker;
      case LocationType.PoliceStation:
        return _policeStationMarker;
      case LocationType.FireStation:
        return _fireStationMarker;
    }
  }

  @override
  Widget build(BuildContext context) {
    _addMarkers();
    return _center == null
        ? const Center(child: CircularProgressIndicator())
        : GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: CameraPosition(target: _center!, zoom: 14.0),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: _markers,
          );
  }
}
