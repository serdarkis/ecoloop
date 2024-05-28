import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File _imageFile = File('');
  int? _selectedMaterial;
  final List<String> _materials = ['Metal', 'Plastik', 'Kağıt', 'Cam'];
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
            DropdownButton<int>(
              hint: Text("Select Material"),
              value: _selectedMaterial,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedMaterial = newValue;
                });
              },
              items: _materials.asMap().entries.map((entry) {
                int idx = entry.key + 1; // index starts from 1
                String value = entry.value;
                return DropdownMenuItem<int>(
                  value: idx,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_imageFile.path.isNotEmpty && _selectedMaterial != null) {
                  _sendImageToApi(_imageFile, _selectedMaterial!);
                } else {
                  print('Image or material not selected');
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

  Future<void> _sendImageToApi(File imageFile, int selectedMaterial) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/user-recycling-material/');
    final request = http.MultipartRequest('POST', url);

    // Add image file
    final imagePart = await http.MultipartFile.fromPath('image', imageFile.path);
    request.files.add(imagePart);

    // Add fields
    request.fields['material'] = selectedMaterial.toString();

    // Add Authorization header
    request.headers['Authorization'] = 'Token $_token';

    // Send request
    final streamedResponse = await request.send();

    // Read response
    final response = await http.Response.fromStream(streamedResponse);

    // Check response code
    if (response.statusCode == 201) {
      // Show success message and navigate to profile screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully')),
      );
      Navigator.pushNamed(context, '/profile');
    } else {
      print('Failed to upload image');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image')),
      );
    }
  }
}