import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;
  DatabaseHelper._();

  // 🔺 VERSION NAIK (WAJIB)
  static const int _dbVersion = 6;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'barbershop_final.db');
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // ================= CREATE DATABASE =================
  Future<void> _createDB(Database db, int version) async {

    /// ===== ADMIN =====
    await db.execute('''
    CREATE TABLE admins(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL
    )
    ''');

    /// ===== CUSTOMER =====
    await db.execute('''
    CREATE TABLE customers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT NOT NULL UNIQUE,
      is_active INTEGER DEFAULT 1
    )
    ''');

    /// ===== CAPSTER =====
    await db.execute('''
    CREATE TABLE capsters(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      is_active INTEGER DEFAULT 1
    )
    ''');

    /// ===== SERVICE =====
    await db.execute('''
    CREATE TABLE services(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      price INTEGER NOT NULL,
      is_active INTEGER DEFAULT 1
    )
    ''');

    /// ===== PRODUCT =====
    await db.execute('''
    CREATE TABLE products(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      price INTEGER NOT NULL,
      is_active INTEGER DEFAULT 1
    )
    ''');

    /// ===== TRANSACTIONS =====
    await db.execute('''
    CREATE TABLE transactions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      trx_code TEXT UNIQUE,
      capster_id INTEGER,
      total INTEGER NOT NULL,
      date TEXT NOT NULL
    )
    ''');

    /// ===== TRANSACTION ITEMS =====
    await db.execute('''
    CREATE TABLE transaction_items(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      transaction_id INTEGER NOT NULL,
      item_type TEXT NOT NULL,
      item_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      price INTEGER NOT NULL,
      qty INTEGER NOT NULL,
      subtotal INTEGER NOT NULL
    )
    ''');

    /// ===== TRANSACTION CUSTOMERS =====
    await db.execute('''
    CREATE TABLE transaction_customers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      transaction_id INTEGER NOT NULL,
      customer_id INTEGER NOT NULL
    )
    ''');

    /// ===== INDEX =====
    await db.execute(
        'CREATE INDEX idx_transactions_date ON transactions(date)'
    );

    /// ===== SEED ADMIN (HASHED) =====
    await db.insert('admins', {
      'username': 'admin',
      'password': sha256.convert(utf8.encode('admin')).toString(),
    });
  }

  // ================= UPGRADE DATABASE =================
  Future<void> _upgradeDB(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {

    if (oldVersion < 6) {

      /// 🔥 1. MIGRASI PASSWORD ADMIN (PLAINTEXT → HASH)
      final admins = await db.query('admins');

      for (final admin in admins) {
        final password = admin['password'] as String;

        // SHA-256 panjangnya 64 char
        if (password.length < 64) {
          final hashed =
          sha256.convert(utf8.encode(password)).toString();

          await db.update(
            'admins',
            {'password': hashed},
            where: 'id = ?',
            whereArgs: [admin['id']],
          );
        }
      }

      /// 🔥 2. MIGRASI TABLE TRANSACTIONS (AMAN)
      await db.execute(
          'ALTER TABLE transactions RENAME TO transactions_old'
      );

      await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trx_code TEXT UNIQUE,
        capster_id INTEGER,
        total INTEGER NOT NULL,
        date TEXT NOT NULL
      )
      ''');

      await db.execute('''
      INSERT INTO transactions (id, trx_code, capster_id, total, date)
      SELECT id, trx_code, capster_id, total, date
      FROM transactions_old
      ''');

      await db.execute('DROP TABLE transactions_old');

      /// 🔥 3. INDEX ULANG
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date)'
      );
    }
  }
}
