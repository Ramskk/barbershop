import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

import '../db/database_helper.dart';
import '../theme/app_theme.dart';
import '../utils/db_backup.dart';
import '../utils/db_restore.dart';
import '../utils/export_excel.dart';

class AccountPage extends StatefulWidget {
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final usernameCtrl = TextEditingController();
  final oldPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool loading = false;

  String _hash(String v) =>
      sha256.convert(utf8.encode(v)).toString();

  @override
  void initState() {
    super.initState();
    loadAdmin();
  }

  Future<void> loadAdmin() async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.query('admins', limit: 1);
    if (res.isNotEmpty) {
      usernameCtrl.text = res.first['username'] as String;
    }
  }

  Future<void> saveAccount() async {
    try {
      if (oldPassCtrl.text.isEmpty ||
          newPassCtrl.text.isEmpty ||
          confirmCtrl.text.isEmpty) {
        throw 'Semua field wajib diisi';
      }

      if (newPassCtrl.text != confirmCtrl.text) {
        throw 'Konfirmasi password tidak sama';
      }

      setState(() => loading = true);

      final db = await DatabaseHelper.instance.database;
      final res = await db.query('admins', limit: 1);
      if (res.isEmpty) throw 'Admin tidak ditemukan';

      final admin = res.first;
      if (admin['password'] != _hash(oldPassCtrl.text)) {
        throw 'Password lama salah';
      }

      await db.update(
        'admins',
        {
          'username': usernameCtrl.text.trim(),
          'password': _hash(newPassCtrl.text),
        },
        where: 'id = ?',
        whereArgs: [admin['id']],
      );

      oldPassCtrl.clear();
      newPassCtrl.clear();
      confirmCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> backupDatabase() async {
    final path = await DbBackup.backupDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup tersimpan:\n$path')),
    );
  }

  Future<void> restoreDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Restore'),
        content: const Text(
          'Semua data akan diganti dari file backup.\n\nLanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('LANJUTKAN'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await DbRestore.restoreDatabase();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore Berhasil'),
        content: const Text(
          'Aplikasi akan ditutup.\nSilakan buka kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => exit(0),
            child: const Text('TUTUP APLIKASI'),
          ),
        ],
      ),
    );
  }

  Future<void> exportExcel() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.rawQuery('SELECT * FROM transactions');

    final path = await ExportExcel.exportReport(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Excel tersimpan:\n$path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akun Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppTheme.card,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: usernameCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: oldPassCtrl,
                    obscureText: true,
                    decoration:
                    const InputDecoration(labelText: 'Password Lama'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: true,
                    decoration:
                    const InputDecoration(labelText: 'Password Baru'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Konfirmasi Password Baru'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: loading ? null : saveAccount,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text('SIMPAN PERUBAHAN'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            color: AppTheme.card,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.backup),
                    label: const Text('BACKUP DATABASE'),
                    onPressed: backupDatabase,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('EXPORT LAPORAN EXCEL'),
                    onPressed: exportExcel,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.restore),
                    label: const Text('RESTORE DATABASE'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                    onPressed: restoreDatabase,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
