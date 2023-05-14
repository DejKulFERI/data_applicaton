import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:data_application/sensorData.dart';
import 'package:data_application/map.dart';
import 'package:data_application/classDeviceData.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:data_application/classUser.dart';

String title = "Map";

User user = User(
  id: '6460efa250efaf7d824e2190',
  username: 'dbencak',
  email: 'domy.bencak@gmail.com',
  password: '\$2b\$10\$krm2pjxoToD7MAqw2800C./FqkbeopoFQIgQcE94jN3MZku4eFoUG',
  faceImagePath: '',
  faceFeaturesPath: '',
);

void main() {
  /*const url = 'http://164.8.209.117:3001/message';
  const message = 'Hello, server!';

  // Send the message as a JSON string in the request body
  http
      .post(Uri.parse(url), body: json.encode({'message': message}))
      .then((response) {
    if (response.statusCode == 200) {
      // Successful response from the server
      print('Message sent successfully');
    } else {
      // Error response from the server
      print('Error sending message. Status code: ${response.statusCode}');
    }
  }).catchError((error) {
    // Error occurred while sending the request
    print('Error sending message: $error');
  });*/

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends MaterialApp {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _timer;
  Timer? _timerForFillArray;
  DeviceData? _deviceData;

  List<double> tempAccelerometerX = [];
  List<double> tempAccelerometerY = [];
  List<double> tempAccelerometerZ = [];
  List<double> tempGyroscopeX = [];
  List<double> tempGyroscopeY = [];
  List<double> tempGyroscopeZ = [];

  void sendDataToServer(DeviceData deviceData) async {
    const url = 'http://164.8.209.117:3001/message';

    // Convert the deviceData object to a JSON string
    final jsonData = json.encode(deviceData.toJson());
    debugPrint(jsonData.toString());

    try {
      // Send the JSON string in the request body with the correct Content-Type header
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonData,
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

  // Declare globally accessible variables for sensor data and location
  List<double> _accelerometerValues = [0, 0, 0];
  List<double> _gyroscopeValues = [0, 0, 0];
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      _getCurrentLocation();

      // new deviceData... change func to take argument devData
      Random random = Random();

      debugPrint("Temp Acc X: $tempAccelerometerX");

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
        user: user.id,
        rating: random.nextDouble() * 100,
      );

      debugPrint(dataToSend.toString());

      _sendDataToServer(dataToSend);

      tempAccelerometerX.clear();
      tempAccelerometerY.clear();
      tempAccelerometerZ.clear();
      tempGyroscopeX.clear();
      tempGyroscopeY.clear();
      tempGyroscopeZ.clear();
    });

    _timerForFillArray =
        Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerForFillArray?.cancel();
    super.dispose();
  }

  ThemeData _currentTheme = ThemeData(primarySwatch: Colors.blue);
  int currentPage = 1;
  List<Widget> pages = [
    MySensorData(title: "Sensor data"),
    MyMap(),
    MySensorData(title: "Profile")
  ];
  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
        icon: Icon(Icons.data_object_rounded), label: "Sensor Data"),
    const NavigationDestination(icon: Icon(Icons.home), label: "Map"),
    const NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
  ];

  void _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      if (mounted) {
        setState(() {
          _currentPosition = position;
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

  // ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.data_array)),
        ],
      ),
      body: pages[currentPage],
      bottomNavigationBar: NavigationBar(
        destinations: _destinations,
        onDestinationSelected: (int index) {
          setState(() {
            currentPage = index;
            title = _destinations[index].label;
            switch (index) {
              case 0:
                _currentTheme = ThemeData(primarySwatch: Colors.green);
                break;
              case 1:
                _currentTheme = ThemeData(primarySwatch: Colors.blue);
                break;
              case 2:
                _currentTheme = ThemeData(primarySwatch: Colors.amber);
                break;
            }
          });
        },
        selectedIndex: currentPage,
      ),
    );
  }
}
