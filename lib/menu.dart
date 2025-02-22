import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobilya/Tumkayitlar2.dart';
import 'package:mobilya/changePasswordScreen.dart';
import 'package:mobilya/kayit_ekle.dart';
import 'package:mobilya/password.dart';
import 'package:mobilya/tumKayitlar.dart';
import 'dart:async';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  String _currentTime = "";

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now().toLocal().toString().substring(0, 19);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Menü",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.person), // Kullanıcı simgesi
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Password()),
                );
              },
              icon: const Icon(Icons.logout_outlined, color: Colors.black),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Arka plan resmi
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/menu.jpg"), // 📌 Arka plan resminin yolu
                  fit: BoxFit.cover, // 📌 Ekrana tam oturmasını sağlar
                ),
              ),
            ),
          ),

          // İçerik bölümü
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 100,
                  child: _buildMenuButton(Icons.list, "Tüm Kayıtlar", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Tumkayitlar()),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 200,
                  height: 100,
                  child: _buildMenuButton(Icons.add, "Kayıt Ekle", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const KayitEkle()),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 200,
                  height: 100,
                  child: _buildMenuButton(Icons.receipt, "Fatura Oluştur", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Tumkayitlar2(),));
                  }),
                ),
              ],
            ),
          ),

          // Sol altta saat ve tarih
          Positioned(
            left: 15,
            bottom: 30,
            child: Text(
              _currentTime,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // 📌 Yazının daha görünür olması için beyaz yap
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),

          // Sağ altta ek metin
          Positioned(
              right: 20,
              bottom: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Developed by Nalbantsoft",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "V1.0.0",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              )
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String title, VoidCallback onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // 📌 Butonları yarı şeffaf yap
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: Icon(icon, color: Colors.black),
      label: Text(title, style: const TextStyle(color: Colors.black, fontSize: 16)),
      onPressed: onTap,
    );
  }
}
