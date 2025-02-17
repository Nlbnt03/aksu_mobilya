import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobilya/database_helper.dart';
import 'package:mobilya/menu.dart';
import 'package:mobilya/process.dart';
import 'package:mobilya/processDetail.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class Tumkayitlar extends StatefulWidget {
  const Tumkayitlar({Key? key}) : super(key: key);

  @override
  State<Tumkayitlar> createState() => _TumkayitlarState();
}

class _TumkayitlarState extends State<Tumkayitlar> {
  List<Process> allProcesses = [];
  List<Process> filteredProcesses = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProcesses();
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
      debugPrint("Veritabanı hatası: $e");
    }
  }

  void _filterProcesses(String query) {
    setState(() {
      filteredProcesses = query.isEmpty
          ? allProcesses
          : allProcesses.where((process) {
        return process.ad.toLowerCase().contains(query.toLowerCase()) ||
            process.soyad.toLowerCase().contains(query.toLowerCase()) ||
            process.telefon.contains(query) ||
            process.adres.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _deleteProcess(Process process) async {
    final db = await DatabaseHelper.instance.database;
    await Process.delete(db, process.id!);

    setState(() {
      allProcesses.remove(process);
      filteredProcesses.remove(process);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red[700],
        content: const Text(
          "Kayıt başarıyla silindi!",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Process process) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text(
            "Silme Onayı",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Bu kaydı silmek istediğinize emin misiniz?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                _deleteProcess(process);
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text("Tüm Kayıtlar", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const Menu()));
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterProcesses,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Ara",
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredProcesses.isEmpty
                ? const Center(
                child: Text("Eşleşen kayıt bulunamadı.",
                    style: TextStyle(color: Colors.white)))
                : ListView.builder(
              itemCount: filteredProcesses.length,
              itemBuilder: (context, index) {
                final process = filteredProcesses[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      "${process.ad} ${process.soyad}",
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
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _showDeleteConfirmation(process),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProcessDetail(process: process)),
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
