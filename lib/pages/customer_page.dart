import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/database_helper.dart';
import '../theme/app_theme.dart';

class CustomerPage extends StatefulWidget {
  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filtered = [];

  final searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    final db = await DatabaseHelper.instance.database;
    customers = await db.query(
      'customers',
      where: 'is_active = 1',
      orderBy: 'name',
    );
    filtered = List.from(customers);
    setState(() {});
  }

  void search(String keyword) {
    final key = keyword.toLowerCase();
    setState(() {
      filtered = customers.where((c) {
        return '${c['name']} ${c['phone']}'
            .toLowerCase()
            .contains(key);
      }).toList();
    });
  }

  void form({Map<String, dynamic>? data}) {
    final nameCtrl = TextEditingController(text: data?['name']);
    final phoneCtrl = TextEditingController(text: data?['phone']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(
          data == null ? 'Tambah Customer' : 'Edit Customer',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'No HP'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
              final db = await DatabaseHelper.instance.database;

              try {
                if (data == null) {
                  await db.insert('customers', {
                    'name': nameCtrl.text,
                    'phone': phoneCtrl.text,
                  });
                } else {
                  await db.update(
                    'customers',
                    {
                      'name': nameCtrl.text,
                      'phone': phoneCtrl.text,
                    },
                    where: 'id=?',
                    whereArgs: [data['id']],
                  );
                }
                Navigator.pop(context);
                loadCustomers();
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No HP sudah terdaftar')),
                );
              }
            },
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }

  void remove(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'customers',
      {'is_active': 0},
      where: 'id=?',
      whereArgs: [id],
    );
    loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => form(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [

          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari nama atau no HP',
              ),
              onChanged: search,
            ),
          ),

          /// LIST CUSTOMER
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final c = filtered[i];
                return Card(
                  child: ListTile(
                    title: Text(c['name']),
                    subtitle: Text(c['phone']),
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
          ),
        ],
      ),
    );
  }
}
