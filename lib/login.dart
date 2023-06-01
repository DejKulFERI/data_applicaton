import 'dart:async';
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
  String email;

  LoginUser({
    required this.username,
    required this.password,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
    };
  }
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _email = '';
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    _timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) async {
      userId = user?.id ?? '';
      username = user?.username ?? '';
      email = user?.email ?? '';
    });
    super.initState();
  }

  void _logout() async {
    // Logout successful
    print('Logout successful');

    // Clear user data from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      isLoggedIn = false;
      user = null;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      LoginUser loginUser =
          LoginUser(username: _username, password: _password, email: _email);
      //const url = 'http://164.8.209.117:3001/user/loginMobile';
      //const url = 'http://127.0.0.1:3001/user/loginMobile';
      const url =
          "http://169.254.156.211:3001/user/loginMobile"; // local FOR EMULATOR - Aljaz

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
            print("Logged in successfully ${_username}");
            prefs.setString('user', json.encode(userJson));
            setState(() {
              isLoggedIn = true;
              User loggedInUser = User.fromJson(userJson);
              user = loggedInUser;
              userId = user?.id ?? '';
              username = user?.username ?? '';
              email = user?.email ?? '';
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
                title: const Text('Authentication Failed'),
                content: const Text('Wrong username or password.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
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
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 16.0),
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
            const Text(
              'Email:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(
                color: Color.fromRGBO(124, 124, 124, 1),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Username:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              username,
              style: const TextStyle(
                color: Color.fromRGBO(124, 124, 124, 1),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'User ID:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userId,
              style: const TextStyle(
                color: Color.fromRGBO(124, 124, 124, 1),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
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
String email = user?.email ?? '';
