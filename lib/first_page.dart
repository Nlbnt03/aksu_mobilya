import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilya/menu.dart';

class FirsPage extends StatefulWidget {
  const FirsPage({super.key});

  @override
  State<FirsPage> createState() => _FirsPageState();
}

class _FirsPageState extends State<FirsPage> {
  String _currentTime = "";
  final TextEditingController _passwordController = TextEditingController();
  String _savedPassword = "123456"; // Varsayılan şifre

  @override
  void initState() {
    super.initState();
    _updateTime();
    _loadSavedPassword(); // Kaydedilmiş şifreyi yükle
  }

  void _updateTime() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now().toLocal().toString().substring(0, 19);
      });
    });
  }

  Future<void> _loadSavedPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPass = prefs.getString('user_password');

    setState(() {
      _savedPassword = savedPass ?? "123456"; // Eğer null ise varsayılan 123456 olacak
    });
  }

  void _checkPassword() {
    String enteredPassword = _passwordController.text;

    if (enteredPassword == _savedPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Menu()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hatalı şifre, tekrar deneyin."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan resmi
          Positioned.fill(
            child: Image.asset(
              "images/harmony.png",
              fit: BoxFit.cover,
            ),
          ),
          // Blur efekti (daha bulanık)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          // Şifre giriş alanı
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 400.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "Hoş Geldiniz" başlığı
                      const Text(
                        "Hoş Geldiniz",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Şifre giriş alanı
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Şifre giriniz",
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Giriş Butonu
                      SizedBox(
                        width: 130,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: _checkPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Giriş"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Saat ve tarih
          Positioned(
            bottom: 50,
            child: Text(
              _currentTime,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
