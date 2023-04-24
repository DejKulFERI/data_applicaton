import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Accelerometer readings:',
            ),
            Text(
              'X: ${_accelerometerValues[0].toStringAsFixed(2)}, '
              'Y: ${_accelerometerValues[1].toStringAsFixed(2)}, '
              'Z: ${_accelerometerValues[2].toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 20),
            const Text(
              'Gyroscope readings:',
            ),
            Text(
              'X: ${_gyroscopeValues[0].toStringAsFixed(2)}, '
              'Y: ${_gyroscopeValues[1].toStringAsFixed(2)}, '
              'Z: ${_gyroscopeValues[2].toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 20),
            Text(
              'Current Time: $_currentTime',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 20),
            Text(
              'Current Location: $_currentLocation',
              style: Theme.of(context).textTheme.headline6,
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
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = 'Lat: ${position.latitude}, Long: ${position.longitude}';
    });
  }
}
