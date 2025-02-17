import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS processes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ad TEXT NOT NULL,
        soyad TEXT NOT NULL,
        telefon TEXT NOT NULL,
        adres TEXT NOT NULL,
        isDetay TEXT NOT NULL,
        kullanilan TEXT NOT NULL,
        teslimTarihi TEXT NOT NULL,
        odemeYontemi TEXT NOT NULL,
        taksitVarMi INTEGER NOT NULL,
        taksitSayisi INTEGER,
        kayitYapan TEXT NOT NULL,
        kayitTarihi TEXT NOT NULL,
        fiyat REAL NOT NULL
      )
    ''');
  }

  Future<void> ensureTableExists() async {
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS processes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ad TEXT NOT NULL,
        soyad TEXT NOT NULL,
        telefon TEXT NOT NULL,
        adres TEXT NOT NULL,
        isDetay TEXT NOT NULL,
        kullanilan TEXT NOT NULL,
        teslimTarihi TEXT NOT NULL,
        odemeYontemi TEXT NOT NULL,
        taksitVarMi INTEGER NOT NULL,
        taksitSayisi INTEGER,
        kayitYapan TEXT NOT NULL,
        kayitTarihi TEXT NOT NULL,
        fiyat REAL NOT NULL
      )
    ''');
  }
}
