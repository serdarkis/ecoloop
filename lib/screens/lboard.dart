import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'camera_screen.dart';

class LBoardScreen extends StatefulWidget {
  @override
  _LBoardScreenState createState() => _LBoardScreenState();
}

class _LBoardScreenState extends State<LBoardScreen> {
  List<dynamic> donationLeaders = []; // Bağış liderleri verilerini tutacak liste

  @override
  void initState() {
    super.initState();
    _fetchDonationLeaders(); // Ekran ilk yüklendiğinde bağış liderlerini çek
  }

  Future<void> _fetchDonationLeaders() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/donation-leaderboard/'));

    if (response.statusCode == 200) {
      setState(() {
        donationLeaders = json.decode(response.body); // API'den alınan veriyi ayrıştır ve listeye ata
      });
    } else {
      print('Failed to load donation leaders');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load donation leaders')),
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
                    // LBoard ekranında zaten olduğu için bir işlem yapmıyoruz
                  },
                ),
                NavBarItem(
                  title: 'Files',
                  onTap: () {
                    Navigator.pushNamed(context, '/files');
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // Bağış Liderleri Tablosu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bağış Liderleri',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: donationLeaders.length,
                      itemBuilder: (context, index) {
                        var leader = donationLeaders[index];
                        return ListTile(
                          
                          title: Text(leader['username']), // Kullanıcı adı
                          trailing: Text('${leader['total_donation']} Bağış'), // Bağış sayısı
                        );
                      },
                    ),
                  ),
                ],
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
