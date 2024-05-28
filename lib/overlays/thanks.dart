import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ThanksOverlay {
  static void show(BuildContext context, Function()? callback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _controller = TextEditingController();
        return AlertDialog(
          title: Text('Bağış Yap'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Bağış Miktarı'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                // Girilen miktarı al
                String donationAmount = _controller.text;
                // POST isteği gönder
                _sendDonationRequest(context, donationAmount, callback);
              },
              child: Text('Onayla'),
            ),
          ],
        );
      },
    );
  }

  static void _sendDonationRequest(BuildContext context, String donationAmount, Function()? callback) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found. Please login again.')),
      );
      return;
    }

    var url = Uri.parse('http://10.0.2.2:8000/api/make-donation/');
    var headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json'
    };
    var body = json.encode({'donation_amount': donationAmount});
    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      Navigator.of(context).pop(); // Overlayi kapat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bağışınız başarıyla yapıldı!')),
      );
      callback?.call(); // Geri çağrı fonksiyonunu çağır
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bağış yapılırken bir hata oluştu!')),
      );
    }
  }
}