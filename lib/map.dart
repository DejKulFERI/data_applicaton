import 'dart:async';
import 'package:data_application/main.dart';
import 'package:data_application/startRide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String? userId = "";
  Marker? marker = Marker(
    point: LatLng(
      0.0,
      0.0,
    ),
    builder: (context) => const Icon(Icons.my_location_rounded),
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    createRide();

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
    _timer?.cancel();
    super.dispose();
  }

  void _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          marker = Marker(
            point: LatLng(
              position.latitude,
              position.longitude,
            ),
            builder: (context) => const Icon(Icons.my_location_rounded),
          );
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

  void createRide() async {
    //const url = 'http://164.8.209.117:3001/carRide/';
    //const url = 'http://127.0.0.1:3001/';
    const url = "http://169.254.99.207:3001/carRide"; // local FOR EMULATOR
    print("Trying to create carRide");

    // Retrieve the logged-in user from shared preferences
    try {
      if (isLoggedIn) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userJson = prefs.getString('user');
        if (userJson != null) {
          Map<String, dynamic> userMap = json.decode(userJson);
          // Save the id of logged in user to then send it to the server
          userId = userMap['_id'];
        }
      }
    } catch (error) {
      print(error);
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user': userId,
        }),
      );

      if (response.statusCode == 200) {
        // Received request from server successfully
      }
    } catch (error) {
      // Error occurred while sending the request
      print('Error sending data: $error');
    }
  }

  void _cancelCarRide() {
    // Add your logic to cancel the car ride here
    // For example, you can show a confirmation dialog and perform necessary actions
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Car Ride'),
          content: Text('Are you sure you want to cancel the car ride?'),
          actions: [
            TextButton(
              onPressed: () {
                // Perform cancel car ride actions
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => MyApp()));
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Map Page'),
          actions: [
            IconButton(onPressed: _cancelCarRide, icon: Icon(Icons.cancel)),
          ],
        ),
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
                marker!,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
