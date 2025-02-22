import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobilya/first_page.dart';
import 'dart:async';

class Password extends StatefulWidget {
  const Password({super.key});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  String _currentTime = "";
  final FocusNode _focusNode = FocusNode(); // Klavye girişlerini dinlemek için

  @override
  void initState() {
    super.initState();
    _updateTime();

    // Sayfa açıldığında klavyeyi otomatik dinlemeye başla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _updateTime() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now().toLocal().toString().substring(0, 19);
      });
    });
  }

  void _handleKeyPress(KeyEvent event) {
    // Kullanıcı herhangi bir tuşa bastığında şifre giriş ekranına yönlendir
    if (event is KeyDownEvent) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FirstPage()), // Şifre ekranı
      );
    }
  }

  void _handleTap() {
    // Kullanıcı fare ile ekrana tıkladığında şifre giriş ekranına yönlendir
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FirstPage()), // Şifre ekranı
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _handleTap, // Fare tıklamalarını dinle
        child: KeyboardListener(
          focusNode: _focusNode, // Klavye girişlerini dinle
          onKeyEvent: _handleKeyPress, // Tuşa basıldığında çalışacak fonksiyon
          child: Stack(
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
                  filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0), // BLUR artırıldı
                  child: Container(
                    color: Colors.black.withOpacity(0.3), // Arka planı koyulaştır
                  ),
                ),
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Bellek sızıntısını önlemek için odak temizleniyor
    super.dispose();
  }
}