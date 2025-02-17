import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobilya/database_helper.dart';
import 'package:mobilya/fisOlustur.dart';
import 'package:mobilya/menu.dart';
import 'package:mobilya/process.dart';
import 'package:mobilya/processDetail.dart';

class Tumkayitlar2 extends StatefulWidget {
  const Tumkayitlar2({Key? key}) : super(key: key);

  @override
  State<Tumkayitlar2> createState() => _Tumkayitlar2State();
}

class _Tumkayitlar2State extends State<Tumkayitlar2> {
  late Future<List<Process>> futureProcesses;
  List<Process> allProcesses = []; // Orijinal tüm kayıtlar
  List<Process> filteredProcesses = []; // Filtrelenmiş kayıtlar
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProcesses();
  }

  String capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  Future<void> _fetchProcesses() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final processes = await Process.getAllOrderedByDate(db);
      setState(() {
        allProcesses = processes;
        filteredProcesses = processes;
      });
    } catch (e) {
      setState(() {
        allProcesses = [];
        filteredProcesses = [];
      });
      debugPrint("Veritabanı hatası: $e");
    }
  }

  void _filterProcesses(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProcesses = allProcesses;
      } else {
        filteredProcesses = allProcesses
            .where((process) =>
        process.ad.toLowerCase().contains(query.toLowerCase()) ||
            process.soyad.toLowerCase().contains(query.toLowerCase()) ||
            process.telefon.contains(query) ||
            process.adres.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _deleteProcessWithUndo(Process process) async {
    try {
      final db = await DatabaseHelper.instance.database;

      await Process.delete(db, process.id!);

      setState(() {
        allProcesses.remove(process);
        filteredProcesses.remove(process);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.grey[900],
          content: const Text("Kayıt silindi. Geri almak için butona tıklayın.", style: TextStyle(color: Colors.white)),
          action: SnackBarAction(
            label: "Geri Al",
            textColor: Colors.orange,
            onPressed: () async {
              await Process.insert(db, process);
              setState(() {
                if (!allProcesses.contains(process)) {
                  allProcesses.add(process);
                }
                if (!filteredProcesses.contains(process)) {
                  filteredProcesses.add(process);
                }
                filteredProcesses.sort((a, b) => b.kayitTarihi.compareTo(a.kayitTarihi));
              });
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint("Kayıt silinemedi: $e");
    }
  }

  Future<void> _showDeleteConfirmation(Process process) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Silme Onayı", style: TextStyle(color: Colors.white)),
          content: const Text("Bu kaydı silmek istediğinize emin misiniz?", style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                _deleteProcessWithUndo(process);
              },
              child: const Text("Sil", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 📌 Arka planı siyah yaptık
      appBar: AppBar(
        backgroundColor: Colors.grey[900], // 📌 Koyu gri arka plan
        title: const Text("Tüm Kayıtlar", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Menu()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              controller: searchController,
              onChanged: _filterProcesses,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                labelText: "Ara",
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: "İsim, telefon veya adres...",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredProcesses.isEmpty
                ? const Center(
              child: Text(
                "Eşleşen kayıt bulunamadı.",
                style: TextStyle(color: Colors.white70),
              ),
            )
                : ListView.builder(
              itemCount: filteredProcesses.length,
              itemBuilder: (context, index) {
                final process = filteredProcesses[index];
                return Card(
                  color: Colors.grey[850], // 📌 Kartları koyu gri yaptık
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      capitalizeWords("${process.ad} ${process.soyad}"),
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Tarih: ${DateFormat('dd/MM/yyyy').format(process.kayitTarihi)} \nTelefon: ${process.telefon}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "₺${process.fiyat.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.greenAccent),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            _showDeleteConfirmation(process);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FisOlustur(process: process)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
