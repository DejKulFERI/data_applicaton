import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:data_application/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data_application/main.dart';
import 'package:data_application/classUser.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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

  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  late Timer _cameraTimer;

  String faceId = '';

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      // Permission granted
    } else {
      // Permission denied
      if (status.isPermanentlyDenied) {
        // The user denied permission permanently, navigate to app settings
        openAppSettings();
      } else {
        // The user denied permission, show a snackbar or display a message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Camera permission denied'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) async {
      userId = user?.id ?? '';
      username = user?.username ?? '';
      email = user?.email ?? '';
    });

    super.initState();
    _initializeCamera();
  }

  /*@override
  void initState() {
    super.initState();
    _requestCameraPermission().then((_) {
      _initializeCamera().then((_) {
        _timer =
            Timer.periodic(const Duration(milliseconds: 500), (Timer t) async {
          userId = user?.id ?? '';
          username = user?.username ?? '';
          email = user?.email ?? '';
        });
      });
    });
  }*/

  @override
  void dispose() {
    _cameraTimer.cancel();
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _takeAndSendPicture() async {
    const url = "http://164.8.209.117:3001/python/checkFace";

    try {
      final XFile? imageFile = await _cameraController.takePicture();

      if (imageFile != null) {
        /*final Directory appDirectory = await getApplicationDocumentsDirectory();
        final String imagePath = '${appDirectory.path}/image.jpg';
        final File savedImageFile = File(imagePath);
        await savedImageFile.writeAsBytes(await imageFile.readAsBytes());

        final String base64Image =
            base64Encode(savedImageFile.readAsBytesSync());

        final Uri url =
            Uri.parse("http://169.254.156.211:3001/python/checkFace");
        final http.Response response = await http.post(
          url,
          body: {'image': base64Image},
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          print('Response: $jsonResponse');
          // Process the response as needed
        } else {
          print('Request failed with status: ${response.statusCode}');
        }*/
        final String imagePath = imageFile.path;
        final File image = File(imagePath);

        // Resize the image using flutter_image_compress
        final Directory appDirectory = await getApplicationDocumentsDirectory();
        final String resizedImagePath =
            '${appDirectory.path}/resized_image.jpg';

        // Set the desired width and height for the resized image
        final int desiredWidth = 360;
        final int desiredHeight = 520;

        // Resize the image and save it to local storage
        await FlutterImageCompress.compressAndGetFile(
          imagePath,
          resizedImagePath,
          minWidth: desiredWidth,
          minHeight: desiredHeight,
          quality: 90,
        );

        print('Image resized and saved: $resizedImagePath');

        // Read the resized image as bytes
        final List<int> imageBytes = await File(resizedImagePath).readAsBytes();
        final String base64Image = base64Encode(imageBytes);

        final Uri url = Uri.parse("http://164.8.209.117:3001/python/checkFace");
        final http.Response response = await http.post(
          url,
          body: {'image': base64Image},
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          print('Response: $jsonResponse');
          faceId = jsonResponse['recognized_person'];
          // Process the response as needed
        } else {
          print('Request failed with status: ${response.statusCode}');
        }
      } else {
        print('No image captured');
      }
    } catch (error) {
      print('Error sending data: $error');
    }
    /*try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = response.body;
        print('Response: $jsonResponse');

        // Process the final response message
        print('Received success response!');
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending request: $error');
    }*/
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
        _cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front),
        ResolutionPreset.medium);

    try {
      await _cameraController.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
    }

    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
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
      const url = 'http://164.8.209.117:3001/user/loginMobile';
      //const url = 'http://127.0.0.1:3001/user/loginMobile';
      //const url = "http://169.254.156.211:3001/user/loginMobile"; // local FOR EMULATOR - Aljaz

      final jsonData = json.encode(loginUser.toJson());

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonData,
        );

        if (response.statusCode == 200) {
          await _takeAndSendPicture();
          // Login successful
          if (faceId == _username) {
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
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Authentication Failed'),
                  content: const Text('2FA failed. Please try again.'),
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

  void sendFaceRequest() async {
    const url = 'http://164.8.209.117:3001/python/checkFace';
    //const url = 'http://127.0.0.1:3001/user/loginMobile';
    //const url = "http://169.254.156.211:3001/python/checkFace"; // local FOR EMULATOR - Aljaz

    /*try {
      await _requestCameraPermission();
      await _initializeCamera(); // Initialize the camera before opening it

      _openCamera();
      print('Taking picture');
      final XFile? imageFile = await _cameraController
          .takePicture(); // Take a picture using the camera

      if (imageFile != null) {
        print('Image captured');
        final Directory appDirectory = await getApplicationDocumentsDirectory();
        final String imagePath =
            '${appDirectory.path}/image.jpg'; // Set the path to save the image

        final File savedImageFile = File(imagePath);
        await savedImageFile.writeAsBytes(await imageFile
            .readAsBytes()); // Save the picture to the specified path

        final response =
            await http.post(Uri.parse(url), body: {'image': imagePath});
        if (response.statusCode == 200) {
          final jsonResponse = response.body;
          print('Response: $jsonResponse');
          // Process the response as needed
        } else {
          print('Request failed with status: ${response.statusCode}');
        }
      } else {
        print('No image captured');
      }
    } catch (error) {
      // Error occurred while sending the request
      print('Error sending data: $error');
    }*/

    try {
      // Ensure that the camera is initialized.
      //await _initializeCamera;

      // Attempt to take a picture and then get the location
      // where the image file is saved.
      //final image = await _cameraController.takePicture();
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
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
                  ElevatedButton(
                    onPressed: sendFaceRequest,
                    child: const Text('Log In using FaceId'),
                  ),
                  if (_isCameraInitialized)
                    Column(
                      children: [
                        Container(
                          width: 150,
                          height: 200,
                          child: CameraPreview(_cameraController),
                        ),
                      ],
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(),
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
