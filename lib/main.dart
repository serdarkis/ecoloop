import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/initial_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/profile.dart';  // Profil ekranı dosyasını içe aktarın
import 'screens/login.dart';  // Giriş ekranı dosyasını içe aktarın
import 'screens/register.dart';
import 'screens/lboard.dart';
import 'screens/aboutus.dart';
import 'screens/files.dart';
import 'screens/camera_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InitialScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/profile': (context) => ProfileScreen(),
        '/lboard': (context) => LBoardScreen(),  // Burada rotayı tanımlıyoruz
        '/aboutus': (context) => AboutUsScreen(),
        '/files': (context) => FilesScreen(),
        '/camera': (context) => CameraScreen(),
      },
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  late Future<SharedPreferences> _prefs;
  late Future<String?> _token;

  @override
  void initState() {
    super.initState();
    _prefs = SharedPreferences.getInstance();
    _token = _prefs.then((prefs) => prefs.getString('token'));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _token,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          final token = snapshot.data;
          if (token != null && token.isNotEmpty) {
            // Token varsa ve boş değilse, doğrudan profil ekranına git
            return ProfileScreen();
          } else {
            // Token yoksa veya boşsa, giriş ekranına git
            return LoginScreen();
          }
        }
      },
    );
  }
}
