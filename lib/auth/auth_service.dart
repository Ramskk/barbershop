import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../db/database_helper.dart';

class AuthService {
  static String _hash(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }

  static Future<void> login({
    required String username,
    required String password,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final res = await db.query(
      'admins',
      where: 'username = ? AND password = ?',
      whereArgs: [username, _hash(password)],
    );

    if (res.isEmpty) {
      throw Exception('Username atau password salah');
    }
  }
}
