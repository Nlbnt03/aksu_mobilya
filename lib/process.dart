import 'package:sqflite/sqflite.dart';

class Process {
  int? id;
  String ad;
  String soyad;
  String telefon;
  String adres;
  String isDetay;
  String kullanilan;
  String teslimTarihi;
  String odemeYontemi;
  bool taksitVarMi;
  int? taksitSayisi;
  String kayitYapan;
  DateTime kayitTarihi;
  double fiyat;

  Process({
    this.id,
    required this.ad,
    required this.soyad,
    required this.telefon,
    required this.adres,
    required this.isDetay,
    required this.kullanilan,
    required this.teslimTarihi,
    required this.odemeYontemi,
    required this.taksitVarMi,
    this.taksitSayisi,
    required this.kayitYapan,
    required this.kayitTarihi,
    required this.fiyat,
  });

  Map<String, dynamic> toMap() {
    return {
      'ad': ad,
      'soyad': soyad,
      'telefon': telefon,
      'adres': adres,
      'isDetay': isDetay,
      'kullanilan': kullanilan,
      'teslimTarihi': teslimTarihi,
      'odemeYontemi': odemeYontemi,
      'taksitVarMi': taksitVarMi ? 1 : 0,
      'taksitSayisi': taksitSayisi,
      'kayitYapan': kayitYapan,
      'kayitTarihi': kayitTarihi.toIso8601String(),
      'fiyat': fiyat,
    };
  }

  static Future<int> insert(Database db, Process process) async {
    return await db.insert('processes', process.toMap());
  }

  static Future<List<Process>> getAllOrderedByDate(Database db) async {
    final List<Map<String, dynamic>> data = await db.query(
      'processes',
      orderBy: 'kayitTarihi DESC', // Yeniden eskiye sıralama
    );
    return data.map((map) => Process.fromMap(map)).toList();
  }
  static Future<int> delete(Database db, int id) async {
    return await db.delete(
      'processes', // Tablo adı
      where: 'id = ?', // Silme kriteri
      whereArgs: [id], // Kriter için argüman
    );
  }
  static Process fromMap(Map<String, dynamic> map) {
    return Process(
      id: map['id'],
      ad: map['ad'],
      soyad: map['soyad'],
      telefon: map['telefon'],
      adres: map['adres'],
      isDetay: map['isDetay'],
      kullanilan: map['kullanilan'],
      teslimTarihi: map['teslimTarihi'],
      odemeYontemi: map['odemeYontemi'],
      taksitVarMi: map['taksitVarMi'] == 1,
      taksitSayisi: map['taksitSayisi'],
      kayitYapan: map['kayitYapan'],
      kayitTarihi: DateTime.parse(map['kayitTarihi']),
      fiyat: map['fiyat'],
    );
  }

  // Veritabanında bir kaydı güncelleme
  static Future<int> update(Database db, Process process) async {
    return await db.update(
      'processes', // Tablo adı
      process.toMap(), // Güncellenmiş veriler
      where: 'id = ?', // Güncellenecek satırın ID'sini belirtir
      whereArgs: [process.id], // ID değeri
    );
  }
}
