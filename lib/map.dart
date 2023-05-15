import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> with TickerProviderStateMixin {
  Position? _currentPosition;
  late MapController _mapController; // Changed to AnimatedMapController
  Timer? _timer;
  bool isCentered = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    _mapController = MapController();

    _timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer t) {
      _getCurrentLocation();
      // Center and zoom to the user's current location
      if (isCentered && _currentPosition != null) {
        setState(() {
          _mapController.move(
            // Use animatedMove instead of move
            LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            17,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(
                  _currentPosition?.latitude ?? 0,
                  _currentPosition?.longitude ?? 0,
                ),
                zoom: 17,
                onPointerUp: (a, b) {
                  setState(() {
                    isCentered = false;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.data_application',
                  additionalOptions: const {
                    'accessToken':
                        'pk.eyJ1IjoiZGJlbmNhayIsImEiOiJjbGhtYXBhY2gxYTJ3M2NueHg2cDdiNDFrIn0.ZhEWmoS3j-tS230DXRrNlQ',
                    'id': 'mapbox.satellite',
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _currentPosition?.latitude ?? 0,
                        _currentPosition?.longitude ?? 0,
                      ),
                      builder: (context) =>
                          const Icon(Icons.my_location_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Center and zoom to the user's current location
            if (_currentPosition != null) {
              setState(() {
                isCentered = true;
                _mapController.move(
                  LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  17,
                );
              });
            }
          },
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }
}
