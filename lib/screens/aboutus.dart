import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hakkımızda / About Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Biz Pamukkale Üniversitesinde okuyan 3 öğrenciyiz.\n'
              'Serdar Kış, Tolga Ersoy ve Yaşar Samed Erol.\n'
              'Bu uygulama bizim Yazılım Mühendisliği dersi için final projemiz.\n'
              'İyi kullanımlar, iyi günler.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Divider(height: 20, thickness: 2, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'We are 3 students studying at Pamukkale University.\n'
              'Serdar Kış, Tolga Ersoy, and Yaşar Samed Erol.\n'
              'This app is our final project for Software Engineering course.\n'
              'Enjoy using it, have a nice day.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
