import 'dart:async';
import 'dart:math';
import 'package:data_application/login.dart';
import 'package:data_application/startRide.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:data_application/sensorData.dart';
import 'package:data_application/map.dart';
import 'package:data_application/classDeviceData.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:data_application/classUser.dart';
import 'package:shared_preferences/shared_preferences.dart';

String title = "Map";

User? user;

bool isLoggedIn = false;

bool sendData = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Retrieve the saved user from shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString('user');

  if (userJson != null) {
    user = User.fromJson(json.decode(userJson));
  }
  if (user != null) {
    isLoggedIn = true;
    userId = user?.id ?? '';
    username = user?.username ?? '';
  }

  runApp(const MaterialApp(home: MyApp()));
}

// DELETE USER!=0 FROM ALL BUT SNED
class MyApp extends MaterialApp {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  ThemeData _currentTheme = ThemeData(primarySwatch: Colors.blue);
  int currentPage = 1;

  List<Widget> pages = [
    MySensorData(title: "Sensor data"),
    //MyMap(),
    StartRide(),
    LoginForm()
  ];
  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
        icon: Icon(Icons.data_object_rounded), label: "Sensor Data"),
    const NavigationDestination(icon: Icon(Icons.home), label: "Ride"),
    const NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
  ];

  // ...

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _currentTheme,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.data_array),
            ),
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
                  _currentTheme = ThemeData(primarySwatch: Colors.deepPurple);
                  break;
              }
            });
          },
          selectedIndex: currentPage,
        ),
      ),
    );
  }
}
