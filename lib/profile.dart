import 'package:data_application/login.dart';
import 'package:flutter/material.dart';
import 'package:data_application/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _logout() async {
    // Logout successful
    print('Logout successful');

    // Clear user data from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');

    setState(() {
      isLoggedIn = false;
      user = null;
    });

    // Navigate to the login screen
    void _logout() async {
      // Logout successful
      print('Logout successful');

      // Clear user data from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');

      setState(() {
        isLoggedIn = false;
        user = null;
      });

      // Navigate to the login screen as the initial route
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the user ID and username from the global 'user' variable
    String userId = user?.id ?? '';
    String username = user?.username ?? '';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'User ID: $userId',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 16),
          Text(
            'Username: $username',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _logout,
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
