import 'package:data_application/main.dart';
import 'package:flutter/material.dart';
import 'map.dart'; // Import the map page file
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StartRide extends StatefulWidget {
  @override
  _StartRideState createState() => _StartRideState();
}

class _StartRideState extends State<StartRide> {
  //URL to connect to server and send a request to create new carRide
  // Changed how data is received on server end to present data on the website for real-time tracking

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            primary: Colors.red,
            padding: EdgeInsets.all(50),
          ),
          child: Text('Start Car Ride'),
          onPressed: () {
            // Navigate to the map page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyMap()),
            );
          },
        ),
      ),
    );
  }
}
