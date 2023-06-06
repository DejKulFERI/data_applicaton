import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class RegisterUser {
  String username;
  String password;
  String email;

  RegisterUser({
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

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _email = '';
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.high,
    );

    await _cameraController!.initialize();

    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      RegisterUser registerUser =
          RegisterUser(username: _username, password: _password, email: _email);
      //const url = 'http://164.8.209.117:3001/user';
      //const url = 'http://127.0.0.1:3001/user';
      const url =
          "http://169.254.156.211:3001/user/mobile"; // local FOR EMULATOR
      final jsonData = json.encode(registerUser.toJson());

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonData,
        );

        if (response.statusCode == 200) {
          // Send the image now (for faceId)
          if (_isCameraInitialized) {
            final XFile? imageFile = await _cameraController!.takePicture();

            if (imageFile != null) {
              final String imagePath = imageFile.path;
              final File image = File(imagePath);

              // Save the captured image to local storage
              final Directory appDirectory =
                  await getApplicationDocumentsDirectory();
              final String savedImagePath =
                  path.join(appDirectory.path, 'captured_image.jpg');
              await image.copy(savedImagePath);

              print('Image saved: $savedImagePath');

              final List<int> imageBytes = await image.readAsBytes();
              final String base64Image = base64Encode(imageBytes);

              final Uri url =
                  Uri.parse("http://169.254.156.211:3001/python/createFace");
              final http.Response response = await http.post(
                url,
                body: {'image': base64Image, 'username': _username},
              );

              if (response.statusCode == 200) {
                final jsonResponse = jsonDecode(response.body);
                print('Response: $jsonResponse');
                // Process the response as needed
              } else {
                print('Request failed with status: ${response.statusCode}');
              }
            } else {
              print('No image captured');
            }
          } else {
            print('Camera not initialized');
          }
          // Registration successful
          print('Registration successful');
          // Perform any necessary actions here (e.g., navigate to another page)
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Registration Successful'),
              content: Text('You are now registered.'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Register'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isCameraInitialized)
                  Container(
                    width: 150,
                    height: 200,
                    child: CameraPreview(_cameraController!),
                  )
                else
                  CircularProgressIndicator(),
                SizedBox(height: 16.0),
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                SizedBox(height: 16.0),
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                  ),
                ),
                SizedBox(height: 16.0),
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
