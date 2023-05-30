import 'package:flutter/material.dart';
import 'map.dart'; // Import the map page file

class StartRide extends StatelessWidget {
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
