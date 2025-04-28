import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import sqflite_common_ffi
import '../util/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final DBHelper _dbHelper = DBHelper();

  DBHelper get dbHelper => _dbHelper;

  // Menginisialisasi sqflite_ffi sebelum digunakan
  static void init() {
    sqfliteFfiInit(); // Inisialisasi FFI
  }

  // **Register User**
  Future<bool> register(
      String email, String password, String name, String role) async {
    final db = await _dbHelper.database;
    try {
      await db.insert(
        'users',
        {'name': name, 'email': email, 'password': password, 'role': role},
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      print("User berhasil didaftarkan!");
      await _dbHelper.printUsers(); // Cek data setelah insert
      return true;
    } catch (e) {
      print("Gagal mendaftar: ${e.toString()}");
      return false;
    }
  }

  // **Login User**
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final db = await _dbHelper.database;

      // Cetak database sebelum login untuk debugging
      print("=== Sebelum Login ===");
      await _dbHelper.printUsers();
      final List<Map<String, dynamic>> users = await db.query(
        'users',
        where: "email = ? AND password = ?",
        whereArgs: [email, password],
        limit: 1,
      );

      print("Users found: $users"); // Tambahkan debugging output

      if (users.isNotEmpty) {
        final user = users.first;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', user['role'] ?? "Tata-Usaha");
        
        return user;
      } else {
        print("Login gagal: User tidak ditemukan atau password salah");
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // **Cek apakah email sudah digunakan**
  Future<bool> emailExists(String email) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: "email = ?",
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<String> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ??
        "Tata Usaha"; // Default ke Tata Usaha jika tidak ada data
  }

  // **Logout (opsional, bisa dihapus)**
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role'); // Hapus role saat logout
  }
}
