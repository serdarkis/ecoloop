import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File _imageFile = File('');
  String? _selectedMaterial;
  String? _username;
  final List<String> _materials = ['Metal', 'Plastik', 'Material 3'];
  late String _token; // Access token

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  // Get token from SharedPreferences
  Future<void> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      _token = token!;
    });
    _fetchName(); // After getting token, fetch username
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile.path.isNotEmpty
                ? Image.file(
              _imageFile,
              height: 200,
            )
                : Text('No image selected.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _getImage(ImageSource.camera);
              },
              child: Text('Take a Photo'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _getImage(ImageSource.gallery);
              },
              child: Text('Select from Gallery'),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              hint: Text("Select Material"),
              value: _selectedMaterial,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMaterial = newValue;
                });
              },
              items: _materials.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_imageFile.path.isNotEmpty &&
                    _selectedMaterial != null &&
                    _username != null) {
                  _sendImageToApi(_imageFile, _selectedMaterial!, _username!);
                } else {
                  print('Image, material, or username not selected');
                }
              },
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Fetch username from API
  Future<void> _fetchName() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/rest-auth/user/'),
      headers: {'Authorization': 'Token $_token'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        _username = data['username'];
      });
    } else {
      _handleError(response);
    }
  }

  Future<void> _sendImageToApi(File imageFile, String selectedMaterial, String username) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/user-recycling-material/');
    final request = http.MultipartRequest('POST', url);

    // Add image file
    final imagePart = await http.MultipartFile.fromPath('image', imageFile.path);
    request.files.add(imagePart);

    // Add fields
    request.fields['material'] = selectedMaterial;
    request.fields['name'] = username;

    // Add Authorization header
    request.headers['Authorization'] = 'Token $_token';

    // Send request
    final streamedResponse = await request.send();

    // Read response
    final response = await http.Response.fromStream(streamedResponse);

    // Check response code
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    } else {
      print('Failed to upload image');
    }
  }

  void _handleError(http.Response response) {
    print('Error: ${response.reasonPhrase}');
    // You can handle the error as needed
  }
}
