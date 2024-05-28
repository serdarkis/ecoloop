import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'camera_screen.dart';

class FilesScreen extends StatefulWidget {
  @override
  _FilesScreenState createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<dynamic> files = []; // API'den gelen dosya verilerini tutacak liste

  @override
  void initState() {
    super.initState();
    _fetchFiles(); // Ekran ilk yüklendiğinde dosyaları çek
    
  }

  Future<void> _fetchFiles() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/user-recycling-material-list/'));

    if (response.statusCode == 200) {
      setState(() {
        files = json.decode(response.body); // API'den alınan veriyi ayrıştır ve listeye ata
      });
    } else {
      print('Failed to load files');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load files')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marka İsmi'),
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
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                NavBarItem(
                  title: 'LBoard',
                  onTap: () {
                    Navigator.pushNamed(context, '/lboard');
                  },
                ),
                NavBarItem(
                  title: 'Files',
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
                itemCount: files.length, // API'den gelen dosya sayısı kadar eleman oluştur
                itemBuilder: (context, index) {
                  var file = files[index];
                  return ListTile(
                    leading: Image.network(file['image_url']), // Fotoğrafın URL'si
                    title: Text(file['title']), // Fotoğrafın başlığı
                    subtitle: Text(file['description']), // Fotoğrafın açıklaması
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
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  NavBarItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
