import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobilya/database_helper.dart';
import 'package:mobilya/menu.dart';
import 'package:mobilya/process.dart';

class KayitEkle extends StatefulWidget {
  const KayitEkle({super.key});

  @override
  State<KayitEkle> createState() => _KayitEkleState();
}

class _KayitEkleState extends State<KayitEkle> {
  // Kontrolcüler
  final TextEditingController adController = TextEditingController();
  final TextEditingController soyadController = TextEditingController();
  final TextEditingController telefonController = TextEditingController();
  final TextEditingController adresController = TextEditingController();
  final TextEditingController isDetayController = TextEditingController();
  final TextEditingController kullanilanController = TextEditingController();
  final TextEditingController teslimTarihiController = TextEditingController();
  final TextEditingController taksitSayisiController = TextEditingController();
  final TextEditingController kayitYapanController = TextEditingController();
  final TextEditingController fiyatController = TextEditingController();

  DateTime? kayitTarihi;
  DateTime? teslimTarihi;
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  String odemeYontemi = "Nakit";
  bool taksitVarMi = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text("Kayıt Ekle", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Menu()));
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Müşteri Bilgileri"),
            _buildTextField(adController, "Ad"),
            _buildTextField(soyadController, "Soyad"),
            _buildTextField(telefonController, "Telefon No", keyboardType: TextInputType.phone),
            _buildTextField(adresController, "Adres"),

            _buildSectionTitle("İş Detayları"),
            _buildTextField(isDetayController, "Yapılan İş"),
            _buildTextField(kullanilanController, "Kullanılan Şeyler"),

            _buildSectionTitle("Teslim Tarihi"),
            _buildDatePicker("Teslim Tarihi", teslimTarihi, (selectedDate) {
              setState(() {
                teslimTarihi = selectedDate;
              });
            }),

            _buildSectionTitle("Ödeme Bilgileri"),
            _buildTextField(fiyatController, "Fiyat"),
            _buildDropdown("Ödeme Yöntemi", ["Nakit", "Kredi"], odemeYontemi, (value) {
              setState(() {
                odemeYontemi = value!;
              });
            }),
            if (odemeYontemi == "Kredi") _buildCheckbox("Taksit Var mı?", taksitVarMi, (value) {
              setState(() {
                taksitVarMi = value!;
              });
            }),
            if (odemeYontemi == "Kredi" && taksitVarMi) _buildTextField(taksitSayisiController, "Taksit Sayısı", keyboardType: TextInputType.number),

            _buildSectionTitle("Kayıt Bilgileri"),
            _buildTextField(kayitYapanController, "Kayıt Yapan Kişi"),
            _buildDatePicker("Kayıt Tarihi", kayitTarihi, (selectedDate) {
              setState(() {
                kayitTarihi = selectedDate;
              });
            }),

            const SizedBox(height: 20),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Divider(thickness: 2, color: Colors.white24),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        style: const TextStyle(color: Colors.white),
        dropdownColor: Colors.grey[900],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        items: items.map((method) => DropdownMenuItem(value: method, child: Text(method, style: const TextStyle(color: Colors.white)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          checkColor: Colors.black,
          activeColor: Colors.white,
          onChanged: onChanged,
        ),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime?) onDateSelected) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date == null ? "$label Seçilmedi" : "$label: ${dateFormat.format(date)}",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[500]),
          onPressed: () async {
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            onDateSelected(selectedDate);
          },
          child: const Text("Seç", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        onPressed: () async {
          final dbHelper = DatabaseHelper.instance;
          await dbHelper.ensureTableExists();

          Process process = Process(
            ad: adController.text,
            soyad: soyadController.text,
            telefon: telefonController.text,
            adres: adresController.text,
            isDetay: isDetayController.text,
            kullanilan: kullanilanController.text,
            teslimTarihi: teslimTarihi != null ? dateFormat.format(teslimTarihi!) : "Belirtilmedi",
            odemeYontemi: odemeYontemi,
            taksitVarMi: taksitVarMi,
            taksitSayisi: taksitVarMi ? int.tryParse(taksitSayisiController.text) : null,
            kayitYapan: kayitYapanController.text,
            kayitTarihi: kayitTarihi ?? DateTime.now(),
            fiyat: double.tryParse(fiyatController.text) ?? 0.0,
          );

          final db = await dbHelper.database;
          await Process.insert(db, process);

          Navigator.pop(context);
        },
        child: const Text("Kayıt Yap", style: TextStyle(fontSize: 16, color: Colors.black)),
      ),
    );
  }
}
