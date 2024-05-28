import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../overlays/thanks.dart';
import 'camera_screen.dart';

class ProfileScreen extends StatefulWidget {
  static final GlobalKey<_ProfileScreenState> profileScreenKey = GlobalKey<_ProfileScreenState>();

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String profileImageUrl = 'https://via.placeholder.com/150';
  String name = 'Loading...';
  int points = 0;
  String donationCount = "0";
  String lastDonationDate = 'Loading...';
  final ImagePicker _picker = ImagePicker();
  String userId = '';

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      await _fetchUserId(token);
      if (userId.isNotEmpty) {
        await _fetchProfileImageUrl(token, userId);
        await _fetchName(token);
        await _fetchPoints(token);
        await _fetchDonationData(token);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found. Please login again.')),
      );
    }
  }

  Future<void> _fetchUserId(String token) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/rest-auth/user/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        userId = data['pk'].toString();
      });
    } else {
      _handleError(response);
    }
  }

  Future<void> _fetchProfileImageUrl(String token, String userId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/kullanici-profilleri/$userId/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        profileImageUrl = data['image'] ?? 'https://via.placeholder.com/150';
      });
    } else {
      _handleError(response);
    }
  }

  Future<void> _fetchName(String token) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/rest-auth/user/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        name = data['username'];
      });
    } else {
      _handleError(response);
    }
  }

  Future<void> _fetchPoints(String token) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/user-points/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        points = data['points'] is int ? data['points'] : int.tryParse(data['points'].toString()) ?? 0;
      });
    } else {
      _handleError(response);
    }
  }

  Future<void> _fetchDonationData(String token) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/user-donations/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      // Eğer veri bir listeyse ve boş değilse, ilk bağış girişini kullanın
      if (data is List && data.isNotEmpty) {
        var donation = data[0];
        setState(() {
          donationCount = donation['amount']; // amount string olarak yayınlanıyor
          lastDonationDate = _formatDate(donation['donation_date']);
        });
      } else {
        setState(() {
          donationCount = '0'; // Henüz bağış yokken string olarak "0"
          lastDonationDate = 'Henüz bağış yok';
        });
      }
    } else {
      _handleError(response);
    }
  }

  String _formatDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('yyyy-MM-dd  HH:mm').format(dateTime);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        profileImageUrl = image.path;
      });
      await _uploadProfileImage(image.path, userId);
    }
  }

  Future<void> _uploadProfileImage(String imagePath, String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found. Please login again.')),
      );
      return;
    }

    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://10.0.2.2:8000/api/profil_resmi_guncelle/'),
    );
    request.headers['Authorization'] = 'Token $token';
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile photo updated successfully')),
      );

      // Tüm profil verilerini yenile
      await loadProfileData();
    } else {
      var responseData = await response.stream.bytesToString();
      _handleError(http.Response(responseData, response.statusCode));
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found. Please login again.')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/rest-auth/logout/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      await prefs.remove('token');
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _handleError(response);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Çıkış Yap'),
          content: Text('Çıkış yapmak istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Evet'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleError(http.Response response) {
    print('Error: ${response.body}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load data: ${response.body}')),
    );
  }

  void _showUpdateUsernameDialog() {
    TextEditingController _usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kullanıcı Adını Güncelle'),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(hintText: 'Yeni kullanıcı adı'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Onayla'),
              onPressed: () {
                String newUsername = _usernameController.text.trim();
                if (newUsername.isNotEmpty) {
                  Navigator.of(context).pop();
                  _updateUsername(newUsername);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUsername(String newUsername) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found. Please login again.')),
      );
      return;
    }

    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/api/rest-auth/user/'),
      headers: {'Authorization': 'Token $token'},
      body: {'username': newUsername},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı adı başarıyla değiştirildi')),
      );
      // Kullanıcı adı başarıyla değiştirildiğinde profil verilerini yenile
      await loadProfileData();
    } else {
      _handleError(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('EcoLoop'),
        backgroundColor: Color(0xFF97E2B5),
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: _showLogoutDialog,
        ),
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
                  isSelected: true,
                  onTap: () {
                    // Profil ekranında zaten olduğu için bir işlem yapmıyoruz
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
                  isSelected: false,
                  onTap: () {
                    Navigator.pushNamed(context, '/files');
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // Profil Bilgileri
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(profileImageUrl),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: _showUpdateUsernameDialog,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Puan Bilgisi
            Text(
              'Puan: $points',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            // Bağış Sayacı
            Text(
              'Toplam Bağışlanan puan: $donationCount',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            // Son Bağış Tarihi
            Text(
              'Son Bağış Tarihi: $lastDonationDate',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Bağış Yap Butonu
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ThanksOverlay.show(context, loadProfileData);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF97E2B5),
                ),
                child: Text('Bağış Yap'),
              ),
            ),
            SizedBox(height: 20),
            // Hakkımızda Butonu
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/aboutus');
                  },
                  child: Text(
                    'Hakkımızda',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/camera');
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
