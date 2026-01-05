import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbRestore {
  static Future<void> restoreDatabase() async {
    final XFile? file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Database',
          extensions: ['db'],
        ),
      ],
    );

    if (file == null) {
      throw Exception('Restore dibatalkan');
    }

    final pickedFile = File(file.path);
    if (!await pickedFile.exists()) {
      throw Exception('File tidak ditemukan');
    }

    final dbPath = join(
      await getDatabasesPath(),
      'barbershop_final.db',
    );

    // Tutup database jika masih terbuka
    try {
      final db = await openDatabase(dbPath);
      await db.close();
    } catch (_) {}

    // Replace database
    if (await File(dbPath).exists()) {
      await File(dbPath).delete();
    }

    await pickedFile.copy(dbPath);
  }
}
