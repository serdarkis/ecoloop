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
  late String _token;

  @override
  void initState() {
    super.initState();
    _getToken();
  }

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Fotoğraf Seç'),
        backgroundColor: Color(0xFF97E2B5),
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
                : Text('Fotoğraf seçilmedi.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _getImage(ImageSource.camera);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFF97E2B5),
              ),
              child: Text('Fotoğraf Çek'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _getImage(ImageSource.gallery);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFF97E2B5),
              ),
              child: Text('Galeriden Seç'),
            ),
            SizedBox(height: 20),
            DropdownButton<int>(
              hint: Text("Malzeme Seç"),
              value: _selectedMaterial,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedMaterial = newValue;
                });
              },
              items: _materials.asMap().entries.map((entry) {
                int idx = entry.key + 1;
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
                  print('Fotoğraf veya malzeme seçilmedi');
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFF97E2B5),
              ),
              child: Text('Fotoğraf Yükle'),
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

    final imagePart = await http.MultipartFile.fromPath('image', imageFile.path);
    request.files.add(imagePart);

    request.fields['material'] = selectedMaterial.toString();

    request.headers['Authorization'] = 'Token $_token';

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf başarıyla yüklendi')),
      );
      Navigator.pushNamed(context, '/profile');
    } else {
      print('Fotoğraf yükleme başarısız');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf yükleme başarısız')),
      );
    }
  }
}
