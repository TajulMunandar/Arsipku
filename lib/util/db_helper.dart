import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            role TEXT
          )
        ''');
      },
    );
  }

  Future<void> printUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query('users');

    print("======= Data Users =======");
    if (users.isEmpty) {
      print("Tidak ada data di tabel users.");
    } else {
      for (var user in users) {
        print(
            "ID: ${user['id']}, Name: ${user['name']}, Email: ${user['email']}, Password: ${user['password']}, Role: ${user['role']}");
      }
    }
    print("==========================");
  }
}
