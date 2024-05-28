import 'package:flutter/material.dart';

class PasswordForgetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forget send'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            SizedBox(height: 20.0),
            Container(
              width: double.infinity,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Add your registration logic here
              },
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PasswordForgetScreen(),
    );
  }
}
