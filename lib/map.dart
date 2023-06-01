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
import 'package:data_application/sensorData.dart';
import 'dart:math';
import 'package:data_application/login.dart';
import 'package:data_application/classDeviceData.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:data_application/classUser.dart';

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> with WidgetsBindingObserver {
  //Position? _currentPosition;
  Future<Position?>? _currentPositionFuture;
  late MapController _mapController; // Changed to AnimatedMapController
  //Timer? _timer;
  bool isCentered = true;
  String? createdCarRideId = "";
  String? userId = "";
  Marker? marker = Marker(
    point: LatLng(
      0.0,
      0.0,
    ),
    builder: (context) => const Icon(Icons.my_location_rounded),
  );

  Timer? _timer;
  Timer? _timerForFillArray;

  List<double> tempAccelerometerX = [];
  List<double> tempAccelerometerY = [];
  List<double> tempAccelerometerZ = [];
  List<double> tempGyroscopeX = [];
  List<double> tempGyroscopeY = [];
  List<double> tempGyroscopeZ = [];

  void sendDataToServer(DeviceData deviceData) async {
    var url =
        'http://164.8.209.117:3001/carRide/${createdCarRideId}/updateRideMobile';
    //const url = 'http://127.0.0.1:3001/deviceData';
    //const url = "http://169.254.99.207:3001/deviceData"; // local FOR EMULATOR
    //var url = "http://169.254.99.207:3001/carRide/${createdCarRideId}/updateRideMobile"; - local testing - aljaz

    print("Trying to send data via url: ${url}");

    // Replace NaN values with 0.0
    deviceData.accelerometerX = deviceData.accelerometerX
        .map((value) => value.isNaN ? 0.0 : value)
        .toList();
    deviceData.accelerometerY = deviceData.accelerometerY
        .map((value) => value.isNaN ? 0.0 : value)
        .toList();
    deviceData.accelerometerZ = deviceData.accelerometerZ
        .map((value) => value.isNaN ? 0.0 : value)
        .toList();
    deviceData.gyroscopeX = deviceData.gyroscopeX
        .map((value) => value.isNaN ? 0.0 : value)
        .toList();
    deviceData.gyroscopeY = deviceData.gyroscopeY
        .map((value) => value.isNaN ? 0.0 : value)
        .toList();
    deviceData.gyroscopeZ = deviceData.gyroscopeZ
        .map((value) => value.isNaN ? 0.0 : value)
        .toList();
    if (deviceData.rating.isNaN) deviceData.rating = 0.0;

    // Convert the deviceData object to a JSON string
    final jsonData = json.encode(deviceData.toJson());

    try {
      // Send the JSON string in the request body with the correct Content-Type header
      /*final finalSend = {
        'accelerometerX': deviceData.accelerometerX,
        'accelerometerY': deviceData.accelerometerY,
        'accelerometerZ': deviceData.accelerometerZ,
        'gyroscopeX': deviceData.gyroscopeX,
        'gyroscopeY': deviceData.gyroscopeY,
        'gyroscopeZ': deviceData.gyroscopeZ,
        'latitude': deviceData.latitude,
        'longitude': deviceData.longitude,
        'timestamp': deviceData.timestamp.toIso8601String(),
        'user': userId,
        'rating': deviceData.rating,
        'carRideId': createdCarRideId
      };

      print("Sending data: ${finalSend}");*/

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonData, //jsonData,
      );

      if (response.statusCode == 200) {
        // Successful response from the server
        print('Data sent successfully');
      } else {
        // Error response from the server
        print('Error sending data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Error occurred while sending the request
      print('Error sending data: $error');
    }
  }

  double calculateSmoothnessRating(List<double> accelerometerX,
      List<double> accelerometerY, List<double> accelerometerZ) {
    if (accelerometerX.length != accelerometerY.length ||
        accelerometerY.length != accelerometerZ.length ||
        accelerometerX.isEmpty) {
      // Return a default value or throw an exception, depending on your requirements
      return 0.0;
    }

    // Calculate the magnitude of acceleration
    List<double> magnitudes = [];
    for (int i = 0; i < accelerometerX.length; i++) {
      double magnitude = sqrt(pow(accelerometerX[i], 2) +
          pow(accelerometerY[i], 2) +
          pow(accelerometerZ[i], 2));
      magnitudes.add(magnitude);
    }

    // Normalize the magnitudes to the range [0, 1]
    double maxMagnitude = magnitudes.reduce(max);
    List<double> normalizedMagnitudes =
        magnitudes.map((magnitude) => magnitude / maxMagnitude).toList();

    // Map the normalized magnitudes to the range [0, 100] for the smoothness rating
    List<double> ratings =
        normalizedMagnitudes.map((magnitude) => magnitude * 100).toList();

    // Calculate the average rating
    double averageRating = ratings.isNotEmpty
        ? ratings.reduce((a, b) => a + b) / ratings.length
        : 0.1;

    return averageRating;
  }

  // Declare globally accessible variables for sensor data and location
  List<double> _accelerometerValues = [0, 0, 0];
  List<double> _gyroscopeValues = [0, 0, 0];
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();

    createRide();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      _getCurrentLocation();

      //debugPrint("Temp Acc X: $tempAccelerometerX");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString('user');

      if (userJson != null) {
        user = User.fromJson(json.decode(userJson));
      }

      DeviceData dataToSend = DeviceData(
        accelerometerX: tempAccelerometerX,
        accelerometerY: tempAccelerometerY,
        accelerometerZ: tempAccelerometerZ,
        gyroscopeX: tempGyroscopeX,
        gyroscopeY: tempGyroscopeY,
        gyroscopeZ: tempGyroscopeZ,
        latitude: _currentPosition?.latitude ?? 0.0,
        longitude: _currentPosition?.longitude ?? 0.0,
        timestamp: DateTime.now(),
        user: user?.id ?? '',
        rating: calculateSmoothnessRating(
            tempAccelerometerX, tempAccelerometerY, tempAccelerometerZ),
        carRideId: createdCarRideId ?? '',
      );

      if (isLoggedIn && sendData) _sendDataToServer(dataToSend);

      tempAccelerometerX.clear();
      tempAccelerometerY.clear();
      tempAccelerometerZ.clear();
      tempGyroscopeX.clear();
      tempGyroscopeY.clear();
      tempGyroscopeZ.clear();
    });

    _timerForFillArray =
        Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      //debugPrint("isLoggedIn: ${isLoggedIn}");
      tempAccelerometerX.add(_accelerometerValues[0]);
      tempAccelerometerY.add(_accelerometerValues[1]);
      tempAccelerometerZ.add(_accelerometerValues[2]);
      tempGyroscopeX.add(_gyroscopeValues[0]);
      tempGyroscopeY.add(_gyroscopeValues[1]);
      tempGyroscopeZ.add(_gyroscopeValues[2]);
    });

    // Register listeners for accelerometer and gyroscope events
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          _accelerometerValues = [event.x, event.y, event.z];
        });
      }
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      if (mounted) {
        setState(() {
          _gyroscopeValues = [event.x, event.y, event.z];
        });
      }
    });

    // Get the current location
    _getCurrentLocation();

    //_getCurrentLocation();

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
    _timerForFillArray?.cancel();
    sendData = false;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print('View closed or deactivated');
      sendData = false;
    }
  }

  /*void _getCurrentLocation() async {
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
  }*/

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
    if (createdCarRideId == "") {
      //const url = 'http://164.8.209.117:3001/carRide/';
      //const url = 'http://127.0.0.1:3001/';
      const url = "http://164.8.209.117:3001/carRide/"; // local FOR EMULATOR
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
          // the server will return a id of the carRide we created
          Map<String, dynamic> responseData = json.decode(response.body);
          createdCarRideId = responseData['id'];
          // we can now start sending the data
          sendData = true;
          print("Car ride successfully created with id: ${createdCarRideId}");
        }
      } catch (error) {
        // Error occurred while sending the request
        print('Error sending data: $error');
      }
    } else {
      print("A carRide was already created");
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
                sendData = false;
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

  void _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
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

  void _sendDataToServer(DeviceData dataToSend) {
    // Create a DeviceData object with the required values

    // Send the deviceData object to the server
    sendDataToServer(dataToSend);
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
