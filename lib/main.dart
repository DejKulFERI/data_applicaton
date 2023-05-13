import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:data_application/sensorData.dart';
import 'package:data_application/map.dart';

String title = "Map";

void main() {
  const url = 'http://164.8.209.117:3001/message';
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
  });

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends MaterialApp {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
                _currentTheme = ThemeData(primarySwatch: myPurple);
                break;
            }
          });
        },
        selectedIndex: currentPage,
      ),
    );
  }
}

MaterialColor? myPurple = const MaterialColor(0xFF6A3DE8, {
  50: Color(0xFFE9E6FC),
  100: Color(0xFFC7BEF6),
  200: Color(0xFFA492EE),
  300: Color(0xFF7E66E6),
  400: Color(0xFF683FD4),
  500: Color(0xFF6A3DE8),
  600: Color(0xFF5F36C2),
  700: Color(0xFF512E9D),
  800: Color(0xFF462776),
  900: Color(0xFF361C51),
});
