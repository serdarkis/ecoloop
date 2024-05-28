import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';
import 'login.dart';
import 'package:http/http.dart' as http;

class InitialScreen extends StatefulWidget {
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      // Token yoksa veya geçersizse, LoginScreen'e yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      // Token varsa, token'ı doğrula
      bool isValidToken = await _validateToken(token);
      if (isValidToken) {
        // Token doğrulandıysa, ProfileScreen'e yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      } else {
        // Token geçersizse, LoginScreen'e yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  Future<bool> _validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/rest-auth/user/'),
        headers: {'Authorization': 'Token $token'},
      );

      print('Token validation response status: ${response.statusCode}');
      print('Token validation response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        return false;
      }
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
