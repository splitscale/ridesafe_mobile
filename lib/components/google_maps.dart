import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:image/image.dart' as img;

class Location {
  final String name;
  final LatLng latLng;
  final String phone;
  final LocationType type;

  Location({
    required this.name,
    required this.latLng,
    required this.phone,
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

  // ignore: prefer_final_fields
  List<Location> _locations = [
    Location(
      name: 'Iloilo Red Cross',
      latLng: const LatLng(10.704088866767679, 122.56845539693349),
      phone: '033 321 3594',
      type: LocationType.Hospital,
    ),
    Location(
      name: 'BFP Iloilo City',
      latLng: const LatLng(10.7045, 122.56794),
      phone: '033 336 2513',
      type: LocationType.FireStation,
    ),
    Location(
      name: 'Barrio Obrero BFP',
      latLng: const LatLng(10.69948, 122.58792),
      phone: '033 335 0215',
      type: LocationType.FireStation,
    ),
    Location(
      name: 'Arevalo BFP',
      latLng: const LatLng(10.6877, 122.5166),
      phone: '033 337 7100',
      type: LocationType.FireStation,
    ),
    Location(
      name: 'Jaro BFP',
      latLng: const LatLng(10.726209554107172, 122.55738818528928),
      phone: '033 329 1993',
      type: LocationType.FireStation,
    ),
    Location(
      name: 'Mandurriao BFP',
      latLng: const LatLng(10.69399786234313, 122.57280802576847),
      phone: '033 321 0565',
      type: LocationType.FireStation,
    ),
    Location(
      name: 'ICAG BFP',
      latLng: const LatLng(10.720612069710988, 122.56204423470204),
      phone: '033 321 2066',
      type: LocationType.FireStation,
    ),
    Location(
      name: 'Iloilo City PNP',
      latLng: const LatLng(10.70236322712234, 122.56420550887631),
      phone: '033 320 8733',
      type: LocationType.PoliceStation,
    ),
    Location(
      name: 'Lapaz PNP',
      latLng: const LatLng(10.712301596459799, 122.5716517025522),
      phone: '033 320 3036',
      type: LocationType.PoliceStation,
    ),
    Location(
      name: 'Molo PNP',
      latLng: const LatLng(10.705330433152415, 122.54383411886329),
      phone: '033 336 2838',
      type: LocationType.PoliceStation,
    ),
    Location(
      name: 'Jaro PNP',
      latLng: const LatLng(10.72602484861084, 122.55910510044669),
      phone: '033 329 4315',
      type: LocationType.PoliceStation,
    ),
    Location(
      name: 'St. Pauls',
      latLng: const LatLng(10.702011874734593, 122.56679854629972),
      phone: '033 320 8733',
      type: LocationType.Hospital,
    ),
    Location(
      name: 'Doctor\'s',
      latLng: const LatLng(10.696793613239848, 122.5543969527578),
      phone: '033 320 8733',
      type: LocationType.Hospital,
    ),
    Location(
      name: 'Western',
      latLng: const LatLng(10.719011991544923, 122.54168142761465),
      phone: '033 320 8733',
      type: LocationType.Hospital,
    ),
    Location(
      name: 'Red Cross Iloilo',
      latLng: const LatLng(10.704088866767679, 122.56845539693349),
      phone: '033 320 8733',
      type: LocationType.FireStation,
    ),
  ];

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

  void _addMarkers() async {
    for (var location in _locations) {
      final Uint8List markerIcon = await _getMarkerIcon(
        location.type == LocationType.Hospital
            ? 'assets/hospital.png'
            : location.type == LocationType.FireStation
                ? 'assets/emergency.png'
                : location.type == LocationType.PoliceStation
                    ? 'assets/police.png'
                    : 'assets/emergency.png',
      );
      _markers.add(
        Marker(
          markerId: MarkerId(location.name),
          position: location.latLng,
          infoWindow: InfoWindow(
            title: location.name,
            snippet: location.phone,
          ),
          // icon load from image
          icon: BitmapDescriptor.fromBytes(markerIcon),
          // change size
        ),
      );
    }

    _markers.add(
      Marker(
        markerId: const MarkerId('Current Location'),
        position: _center!,
        infoWindow: const InfoWindow(
          title: 'Current Location',
        ),
      ),
    );
  }

  Future<Uint8List> _getMarkerIcon(String assetName) async {
    final image = await rootBundle.load(assetName);
    final codec = await instantiateImageCodec(image.buffer.asUint8List(),
        targetHeight: 100);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ImageByteFormat.png);
    return data!.buffer.asUint8List();
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
