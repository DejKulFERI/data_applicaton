import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  Position? _currentPosition;
  Future<Position?>? _currentPositionFuture;
  late MapController _mapController; // Changed to AnimatedMapController
  Timer? _timer;
  bool isCentered = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    _mapController = MapController();

    _currentPositionFuture = _getCurrentLocationFuture();

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

  Future<Position?> _getCurrentLocationFuture() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder<Position?>(
          future: _currentPositionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final position = snapshot.data;
              return _buildMap(position);
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _currentPositionFuture = _getCurrentLocationFuture();
            setState(() {
              isCentered = true;
            });
          },
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }

  Widget _buildMap(Position? position) {
    return Center(
      child: SizedBox(
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: LatLng(
              position?.latitude ?? 0,
              position?.longitude ?? 0,
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
                    position?.latitude ?? 0,
                    position?.longitude ?? 0,
                  ),
                  builder: (context) => const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
