import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'camera_screen.dart';

class FilesScreen extends StatefulWidget {
  @override
  _FilesScreenState createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<dynamic> files = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      await _fetchFiles(token);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found. Please login again.')),
      );
    }
  }

  Future<void> _fetchFiles(String token) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/user-recycling-material-list/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        files = json.decode(response.body);
      });
    } else {
      print('Failed to load files');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load files')),
      );
    }
  }

  String getMaterialType(int material) {
    switch (material) {
      case 1:
        return 'Metal';
      case 2:
        return 'Plastik';
      case 3:
        return 'Kağıt';
      case 4:
        return 'Cam';
      default:
        return 'Bilinmiyor';
    }
  }

  int getMaterialPoints(int material) {
    switch (material) {
      case 1:
        return 50;
      case 2:
        return 40;
      case 3:
        return 60;
      case 4:
        return 30;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EcoLoop'),
        backgroundColor: Color(0xFF97E2B5),
        leading: Container(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Navbar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavBarItem(
                  title: 'Profil',
                  icon: Icons.person,
                  isSelected: false,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                NavBarItem(
                  title: 'Lider T.',
                  icon: Icons.leaderboard,
                  isSelected: false,
                  onTap: () {
                    Navigator.pushNamed(context, '/lboard');
                  },
                ),
                NavBarItem(
                  title: 'Dosya',
                  icon: Icons.file_present,
                  isSelected: true,
                  onTap: () {
                    // Files ekranında zaten olduğu için bir işlem yapmıyoruz
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // Fotoğrafların listesi
            Expanded(
              child: ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  var file = files[index];
                  String materialType = getMaterialType(file['material']);
                  int materialPoints = getMaterialPoints(file['material']);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Image.network(
                          file['image'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$materialType', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('Puan: $materialPoints', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CameraScreen()),
          );
        },
        backgroundColor: Color(0xFF97E2B5),
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  NavBarItem({required this.title, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: isSelected ? Color(0xFF97E2B5) : Colors.grey),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: isSelected ? Color(0xFF97E2B5) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
