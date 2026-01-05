import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbBackup {
  static Future<String> backupDatabase() async {
    // lokasi database sqlite
    final dbPath = join(
      await getDatabasesPath(),
      'barbershop_final.db',
    );

    final dbFile = File(dbPath);
    if (!await dbFile.exists()) {
      throw Exception('Database tidak ditemukan');
    }

    // 🔥 FOLDER DOWNLOAD (PUBLIC)
    final downloadDir = Directory('/storage/emulated/0/Download/HexaBarbershop');

    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    final now = DateTime.now();
    final fileName =
        'barbershop_backup_${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}.db';

    final backupPath = join(downloadDir.path, fileName);

    await dbFile.copy(backupPath);

    return backupPath;
  }
}
