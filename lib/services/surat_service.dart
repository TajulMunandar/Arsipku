import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/surat_model.dart';

class SuratService {
  static final SuratService instance = SuratService._init();
  static Database? _database;

  SuratService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('surat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE surat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jenis_surat TEXT,
        nomor_surat TEXT NOT NULL,
        tanggal_surat TEXT NOT NULL,
        pengirim TEXT NOT NULL,
        penerima TEXT NOT NULL,
        perihal TEXT NOT NULL,
        file_url TEXT,
        status TEXT
      )
    ''');
  }

  // Tambah Surat
  Future<int> tambahSurat(Surat surat) async {
    final db = await database;
    return await db.insert('surat', surat.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Ambil semua surat (masuk/keluar)
  Future<List<Surat>> getSurat(String jenisSurat) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'surat',
      where: 'jenis_surat = ?',
      whereArgs: [jenisSurat],
    );

    return maps.map((map) => Surat.fromMap(map)).toList();
  }

  // Edit Surat
  Future<int> editSurat(Surat surat) async {
    final db = await database;
    return await db.update(
      'surat',
      surat.toMap(),
      where: 'id = ?',
      whereArgs: [surat.id ?? 0],
    );
  }

  Future<List<String>> getTahunSurat(String jenisSurat) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
    SELECT DISTINCT strftime('%Y', tanggal_surat) as tahun 
    FROM surat 
    WHERE jenis_surat = ?
    ORDER BY tahun DESC
    ''',
      [jenisSurat],
    );

    // Tangani jika hasilnya null atau tidak bertipe String
    return result
        .map((e) => e['tahun']?.toString() ?? '')
        .where((tahun) => tahun.isNotEmpty)
        .toList();
  }

  Future<List<Surat>> getSuratByTahun(String jenisSurat, String tahun) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
    SELECT * FROM surat 
    WHERE jenis_surat = ? AND strftime('%Y', tanggal_surat) = ?
    ORDER BY tanggal_surat DESC
    ''',
      [jenisSurat, tahun],
    );

    return result.map((e) => Surat.fromMap(e)).toList();
  }

  // Hapus Surat
  Future<int> hapusSurat(int id) async {
    // Ubah tipe parameter ke int
    final db = await database;
    return await db.delete(
      'surat',
      where: 'id = ?',
      whereArgs: [id], // id tetap bertipe int
    );
  }

  Future<int> getJumlahSurat(String jenis) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as total FROM surat WHERE jenis_surat = ?', [jenis]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<int>> getJumlahSuratPerHari(String jenis) async {
    final db = await database;
    final now = DateTime.now();
    List<int> jumlahPerHari = [];

    for (int i = 0; i <= 6; i--) {
      final tanggal =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final tanggalString =
          "${tanggal.year.toString().padLeft(4, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}";

      final result = await db.rawQuery(
        'SELECT COUNT(*) as total FROM surat WHERE jenis_surat = ? AND DATE(tanggal_surat) = ?',
        [jenis, tanggalString],
      );

      final count = Sqflite.firstIntValue(result) ?? 0;
      jumlahPerHari.add(count);
    }

    return jumlahPerHari;
  }
}
