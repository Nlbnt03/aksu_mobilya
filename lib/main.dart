import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobilya/database_helper.dart';
import 'package:mobilya/password.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Windows için SQLite yapılandırması
  if (Platform.isWindows) {
    // Windows'ta SQLite'ı başlat
    sqfliteFfiInit();
    // Windows için varsayılan factory'i ayarla
    databaseFactory = databaseFactoryFfi;
  }

  // Flutter binding'i başlat
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Veritabanını başlat
    await DatabaseHelper.instance.database;

    // Uygulamayı başlat
    runApp(const MyApp());
  } catch (e) {
    print('Veritabanı başlatma hatası: $e');
    // Hata durumunda da uygulamayı başlat
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AKSU Mobilya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const Password(),
    );
  }
}