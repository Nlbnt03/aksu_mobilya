import 'package:flutter/material.dart';
import 'package:mobilya/database_helper.dart';
import 'package:mobilya/process.dart';
import 'package:mobilya/tumKayitlar.dart';
import 'package:intl/intl.dart';

class ProcessDetail extends StatefulWidget {
  final Process process;

  const ProcessDetail({Key? key, required this.process}) : super(key: key);

  @override
  State<ProcessDetail> createState() => _ProcessDetailState();
}

class _ProcessDetailState extends State<ProcessDetail> {
  late Process updatedProcess;
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    updatedProcess = widget.process;
  }

  String capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  Future<void> _editField(String title, String currentValue, Function(String) onUpdate) async {
    final TextEditingController controller = TextEditingController(text: currentValue);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("$title Düzenle", style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: title,
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                setState(() {
                  onUpdate(controller.text);
                });
                Navigator.pop(context);
              },
              child: const Text("Kaydet", style: TextStyle(color: Colors.white)),
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
        title: const Text("İşlem Detayları", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Tumkayitlar()));
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final field in [
              {'label': 'Ad', 'value': updatedProcess.ad, 'onUpdate': (val) => updatedProcess.ad = val},
              {'label': 'Soyad', 'value': updatedProcess.soyad, 'onUpdate': (val) => updatedProcess.soyad = val},
              {'label': 'Telefon', 'value': updatedProcess.telefon, 'onUpdate': (val) => updatedProcess.telefon = val},
              {'label': 'Adres', 'value': updatedProcess.adres, 'onUpdate': (val) => updatedProcess.adres = val},
              {'label': 'Yapılan İş', 'value': updatedProcess.isDetay, 'onUpdate': (val) => updatedProcess.isDetay = val},
              {'label': 'Kullanılan Malzemeler', 'value': updatedProcess.kullanilan, 'onUpdate': (val) => updatedProcess.kullanilan = val},
              {'label': 'Teslim Tarihi', 'value': updatedProcess.teslimTarihi, 'onUpdate': (val) => updatedProcess.teslimTarihi = val},
              {'label': 'Kayıt Yapan', 'value': updatedProcess.kayitYapan, 'onUpdate': (val) => updatedProcess.kayitYapan = val},
              {'label': 'Fiyat', 'value': "${updatedProcess.fiyat.toStringAsFixed(2)} TL", 'onUpdate': (val) => updatedProcess.fiyat = double.tryParse(val) ?? 0.0},

              // ✅ **Ödeme yöntemi ve taksit detaylarını ekledik**
              {'label': 'Ödeme Yöntemi', 'value': updatedProcess.odemeYontemi, 'onUpdate': (val) => updatedProcess.odemeYontemi = val},
              if (updatedProcess.odemeYontemi == "Kredi")
                {'label': 'Taksit Sayısı', 'value': updatedProcess.taksitSayisi?.toString() ?? "Belirtilmedi", 'onUpdate': (val) => updatedProcess.taksitSayisi = int.tryParse(val)},
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${field['label']}: ${capitalizeWords(field['value'] as String)}",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    PopupMenuButton<String>(
                      color: Colors.grey[850],
                      icon: const Icon(Icons.more_vert, color: Colors.white), // **Beyaz ikon**
                      onSelected: (value) {
                        if (value == 'Düzenle') {
                          _editField(
                            field['label'] as String,
                            field['value'] as String,
                            field['onUpdate'] as Function(String),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'Düzenle',
                          child: Text("Düzenle", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final db = await DatabaseHelper.instance.database;
                    await Process.update(db, updatedProcess);

                    setState(() {});

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.grey[900],
                        title: const Text("Başarılı", style: TextStyle(color: Colors.white)),
                        content: const Text("Veriler başarıyla güncellendi.", style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Tamam", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    "Verileri Güncelle",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
