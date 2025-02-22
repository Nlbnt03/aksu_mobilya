import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobilya/Tumkayitlar2.dart';
import 'package:mobilya/database_helper.dart';
import 'package:mobilya/process.dart';
import 'package:mobilya/tumKayitlar.dart';
import 'package:intl/intl.dart'; // Tarih formatlamak için intl paketi
import 'package:pdf/pdf.dart'; // PDF oluşturmak için
import 'package:pdf/widgets.dart' as pw; // PDF widgetları
import 'package:path_provider/path_provider.dart'; // Dosya yolu için
import 'package:open_file/open_file.dart'; // Dosya açmak için
import 'dart:io'; // Dosya işlemleri için

class FisOlustur extends StatefulWidget {
  final Process process;

  const FisOlustur({Key? key, required this.process}) : super(key: key);

  @override
  State<FisOlustur> createState() => _FisOlusturState();
}

class _FisOlusturState extends State<FisOlustur> {
  late Process updatedProcess; // Güncellenen veri için
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy'); // Tarih formatı

  @override
  void initState() {
    super.initState();
    updatedProcess = widget.process; // Başlangıçta gelen veri
  }

  // Kelimelerin ilk harfini büyük yapar
  String capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word; // Boş kelimeleri değiştirme
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  Future<void> _editField(String title, String currentValue, Function(String) onUpdate) async {
    final TextEditingController controller = TextEditingController(text: currentValue);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$title Düzenle"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: title),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red
              ),
              onPressed: () {
                Navigator.pop(context); // Dialog'u kapat
              },
              child: const Text("İptal",style: TextStyle(color: Colors.white),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green
              ),
              onPressed: () {
                setState(() {
                  onUpdate(controller.text); // Yeni değerle güncelleme
                });
                Navigator.pop(context); // Dialog'u kapat
              },
              child: const Text("Kaydet",style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateAndSavePDF() async {
    final pdf = pw.Document();

    // Özel yazı tipini yükleme
    final robotoFont = await rootBundle.load("fonts/roboto.ttf");
    final roboto = pw.Font.ttf(robotoFont);

    // Logoyu yükleme
    final logoImage = await rootBundle.load("images/AKSU.png");
    final logo = pw.MemoryImage(logoImage.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Image(logo, width: 150, height: 150), // Logoyu ekleme
                  pw.SizedBox(width: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("AKSU Mobilya & Döşeme",
                          style: pw.TextStyle(font: roboto, fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text("Adres:Lalapaşa Mahallesi Piri Reis Sokak Binton Apartmanı Altı",
                          style: pw.TextStyle(font: roboto, fontSize: 12)),
                      pw.Text("Fatih Aksu: 0536 760 8558", style: pw.TextStyle(font: roboto, fontSize: 12)),
                      pw.Text("Telefon: 0442 235 6376", style: pw.TextStyle(font: roboto, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Padding(
                child: pw.Text("İş Detayları", style: pw.TextStyle(font: roboto, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                padding: pw.EdgeInsets.only(left: 10)
              ),
              pw.SizedBox(height: 10),
              pw.Padding(
                child:_buildTextRow("Ad", updatedProcess.ad, roboto),
                padding: pw.EdgeInsets.only(left: 10)
              ),
              pw.Padding(
                  child:_buildTextRow("Soyad", updatedProcess.soyad, roboto),
                  padding: pw.EdgeInsets.only(left: 10)
              ),
              pw.Padding(
                  child:_buildTextRow("Telefon", updatedProcess.telefon, roboto),
                  padding: pw.EdgeInsets.only(left: 10)
              ),
              pw.Padding(
                  child:_buildTextRow("Yapılan İş", updatedProcess.isDetay, roboto),
                  padding: pw.EdgeInsets.only(left: 10)
              ),
              pw.Padding(
                  child:_buildTextRow("Kullanılan Malzemeler", updatedProcess.kullanilan, roboto),
                  padding: pw.EdgeInsets.only(left: 10)
              ),
              pw.Padding(
                  child:  _buildTextRow("Teslim Tarihi", updatedProcess.teslimTarihi, roboto),
                  padding: pw.EdgeInsets.only(left: 10)
              ),
              pw.Padding(
                  child: _buildTextRow("Kayıt Yapan", updatedProcess.kayitYapan, roboto),
                  padding: pw.EdgeInsets.only(left: 10)
              ),
              pw.Padding(
                  child: _buildTextRow("Fiyat", "${updatedProcess.fiyat.toStringAsFixed(2)} TL".toUpperCase(), roboto),
                  padding: pw.EdgeInsets.only(left: 10)
              ),
              pw.Padding(
                  child: // ✅ Ödeme yöntemi ekledik
                  _buildTextRow("Ödeme Yöntemi", updatedProcess.odemeYontemi, roboto),
                  padding: pw.EdgeInsets.only(left: 10)
              ),

              if (updatedProcess.odemeYontemi == "Kredi")
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 10),
                  child: _buildTextRow("Taksit Sayısı", updatedProcess.taksitSayisi?.toString() ?? "Belirtilmedi", roboto),
                ),

              pw.SizedBox(height: 20),
              pw.Text(
                "Yukarıda belirtilen tüm bilgileri okuduğumu, anladığımı ve kabul ettiğimi beyan ederim.",
                style: pw.TextStyle(font: roboto, fontSize: 12),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 40),
              _buildSignatureSection(roboto),
            ],
          );
        },
      ),
    );

    // PDF'i geçici bir dosyaya kaydet
    final output = await getApplicationDocumentsDirectory(); // Daha güvenilir dizin
    final file = File('${output.path}/fis.pdf');
    await file.writeAsBytes(await pdf.save());

    try {
      await OpenFile.open(file.path);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("PDF Açılamadı"),
          content: Text("Lütfen bir PDF okuyucu yükleyin."),
        ),
      );
    }
  }
  pw.Widget _buildTextRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Text("$label:", style: pw.TextStyle(font: font, fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 5),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 12)),
        ],
      ),
    );
  }
  pw.Widget _buildSignatureSection(pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Tarih: ${dateFormat.format(DateTime.now())}", style: pw.TextStyle(font: font, fontSize: 12)),
            pw.SizedBox(height: 10),
            pw.Text("İşyeri Sahibi", style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text("Ad Soyad", style: pw.TextStyle(font: font, fontSize: 12)),
            pw.Text("İmza", style: pw.TextStyle(font: font, fontSize: 12)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text("Tarih: ${dateFormat.format(DateTime.now())}", style: pw.TextStyle(font: font, fontSize: 12)),
            pw.SizedBox(height: 10),
            pw.Text("Müşteri", style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text("Ad Soyad", style: pw.TextStyle(font: font, fontSize: 12)),
            pw.Text("İmza", style: pw.TextStyle(font: font, fontSize: 12)),
          ],
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "İşlem Detayları",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Tumkayitlar2()),
            );
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
              {'label': 'Fiyat', 'value': "${updatedProcess.fiyat.toStringAsFixed(2)} TL".toUpperCase(), 'onUpdate': (val) => updatedProcess.fiyat = double.tryParse(val) ?? 0.0},

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
                      icon: const Icon(Icons.more_vert, color: Colors.white),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _generateAndSavePDF,
                  child: const Text(
                    "Yazdır",
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