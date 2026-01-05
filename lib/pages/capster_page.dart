import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme/app_theme.dart';

class CapsterPage extends StatefulWidget {
  @override
  State<CapsterPage> createState() => _CapsterPageState();
}

class _CapsterPageState extends State<CapsterPage> {
  List<Map<String, dynamic>> capsters = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final db = await DatabaseHelper.instance.database;
    capsters = await db.query(
      'capsters',
      where: 'is_active = 1',
      orderBy: 'name',
    );
    setState(() {});
  }

  void form({Map<String, dynamic>? data}) {
    final ctrl = TextEditingController(text: data?['name']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(
          data == null ? 'Tambah Capster' : 'Edit Capster',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Nama Capster'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isEmpty) return;
              final db = await DatabaseHelper.instance.database;

              if (data == null) {
                await db.insert('capsters', {'name': ctrl.text});
              } else {
                await db.update(
                  'capsters',
                  {'name': ctrl.text},
                  where: 'id=?',
                  whereArgs: [data['id']],
                );
              }

              Navigator.pop(context);
              load();
            },
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }

  Future<void> remove(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'capsters',
      {'is_active': 0},
      where: 'id=?',
      whereArgs: [id],
    );
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capster')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => form(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: capsters.length,
        itemBuilder: (_, i) {
          final c = capsters[i];
          return Card(
            child: ListTile(
              title: Text(c['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => form(data: c),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => remove(c['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
