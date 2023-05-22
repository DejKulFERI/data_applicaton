import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:data_application/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data_application/main.dart';
import 'package:data_application/classUser.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class LoginUser {
  String username;
  String password;

  LoginUser({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

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
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      LoginUser loginUser = LoginUser(username: _username, password: _password);
      const url = 'http://164.8.209.117:3001/user/loginMobile';

      final jsonData = json.encode(loginUser.toJson());

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonData,
        );

        if (response.statusCode == 200) {
          // Login successful

          // Save user locally
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var userJson = json.decode(response.body)['user'];
          if (userJson != null) {
            prefs.setString('user', json.encode(userJson));
            setState(() {
              isLoggedIn = true;
              User loggedInUser = User.fromJson(json.decode(userJson));
              user = loggedInUser;
              userId = user?.id ?? '';
              username = user?.username ?? '';
            });
          } else {
            // Handle the case where 'user' is null
            print('User data is null');
          }
        } else if (response.statusCode == 401) {
          // Authentication failed
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Authentication Failed'),
                content: Text('Wrong username or password.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          // Error response from the server
          print('Error sending data. Status code: ${response.statusCode}');
        }
      } catch (error) {
        // Error occurred while sending the request
        print('Error sending data: $error');
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return ProfilePage(logoutCallback: _logout);
    } else {
      return Scaffold(
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _username = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Log In'),
                  ),
                  const SizedBox(height: 32.0),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterForm(),
                        ),
                      );
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

class ProfilePage extends StatelessWidget {
  final VoidCallback logoutCallback;

  const ProfilePage({required this.logoutCallback});

  @override
  Widget build(BuildContext context) {
    // Access the user ID and username from the global 'user' variable

    return Scaffold(
      body: Center(
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
              onPressed: logoutCallback,
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}

String userId = user?.id ?? '';
String username = user?.username ?? '';
