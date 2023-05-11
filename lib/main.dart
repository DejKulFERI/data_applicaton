import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

void main() async {
  Socket socket = await Socket.connect('164.8.209.117', 8080);
  socket.write('Hello, server!');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NPO Projekt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'NPO - Data application'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<double> _accelerometerValues = [0, 0, 0];
  List<double> _gyroscopeValues = [0, 0, 0];
  String _currentTime = "";
  String _currentLocation = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      _getCurrentTime();
      _getCurrentLocation();
    });

    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = [event.x, event.y, event.z];
      });
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = [event.x, event.y, event.z];
      });
    });

    _getCurrentTime();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  IconData _icon = Icons.code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [IconButton(onPressed: () {}, icon: Icon(_icon))],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //ACCELEROMETER
            const Text('Accelerometer readings:',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                )),
            //ROW OF THE ACCELEROMETER READING
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'X: ',
                  style: TextStyle(
                    color: Color.fromRGBO(147, 0, 0, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_accelerometerValues[0].toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color.fromRGBO(255, 0, 0, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(' - ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )),
                const Text(
                  'Y: ',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 108, 0, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_accelerometerValues[1].toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color.fromRGBO(30, 179, 0, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(' - ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )),
                const Text(
                  'Z: ',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 255, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_accelerometerValues[2].toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color.fromRGBO(0, 191, 229, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Gyroscope readings:',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                )),
            //ROW OF THE GYROSCOPE READING
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'X: ',
                  style: TextStyle(
                    color: Color.fromRGBO(147, 0, 0, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_gyroscopeValues[0].toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color.fromRGBO(255, 0, 0, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(' - ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )),
                const Text(
                  'Y: ',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 108, 0, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_gyroscopeValues[1].toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color.fromRGBO(30, 179, 0, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(' - ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )),
                const Text(
                  'Z: ',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 255, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_gyroscopeValues[2].toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color.fromRGBO(0, 191, 229, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            //CURRENT TIME
            const SizedBox(height: 20),
            const Text('Current Time:',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                )),
            Text(
              '$_currentTime',
              style: const TextStyle(
                color: Color.fromRGBO(124, 124, 124, 1),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Current Location: ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              ' $_currentLocation ',
            ),
          ],
        ),
      ),
    );
  }

  void _getCurrentTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = '${now.hour}:${now.minute}:${now.second}';
    });
  }

  void _getCurrentLocation() async {
    final permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation =
            'LATITUDE: ${position.latitude}\n LONGITUDE: ${position.longitude}';
      });
    } else {
      setState(() {
        _currentLocation = 'Permission denied';
      });
    }
  }
}
