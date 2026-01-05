import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class ServicePage extends StatefulWidget {
  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  List<Map<String, dynamic>> services = [];

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    final db = await DatabaseHelper.instance.database;
    services = await db.query(
      'services',
      where: 'is_active = 1',
      orderBy: 'name',
    );
    setState(() {});
  }

  void saveService({int? id}) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    if (id != null) {
      final s = services.firstWhere((e) => e['id'] == id);
      nameCtrl.text = s['name'];
      priceCtrl.text = s['price'].toString();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Tambah Layanan' : 'Edit Layanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;

              final db = await DatabaseHelper.instance.database;
              final data = {
                'name': nameCtrl.text,
                'price': int.parse(priceCtrl.text),
              };

              if (id == null) {
                await db.insert('services', data);
              } else {
                await db.update(
                  'services',
                  data,
                  where: 'id = ?',
                  whereArgs: [id],
                );
              }

              Navigator.pop(context);
              loadServices();
            },
            child: const Text('Simpan'),
          )
        ],
      ),
    );
  }

  void deleteService(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'services',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Layanan')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => saveService(),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: services.map((s) {
          return ListTile(
            title: Text(s['name']),
            subtitle: Text('Rp ${s['price']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => saveService(id: s['id']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteService(s['id']),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
