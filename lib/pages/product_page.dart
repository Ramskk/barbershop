import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../theme/app_theme.dart';

class ProductPage extends StatefulWidget {
  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final currency = NumberFormat('#,##0', 'id_ID');
  List<Map<String, dynamic>> products = [];

  String rupiah(int v) => 'Rp ${currency.format(v)}';

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final db = await DatabaseHelper.instance.database;
    products = await db.query(
      'products',
      where: 'is_active = 1',
      orderBy: 'name',
    );
    setState(() {});
  }

  void saveProduct({int? id}) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    if (id != null) {
      final p = products.firstWhere((e) => e['id'] == id);
      nameCtrl.text = p['name'];
      priceCtrl.text = p['price'].toString();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(
          id == null ? 'Tambah Produk' : 'Edit Produk',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Produk'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;

              final db = await DatabaseHelper.instance.database;
              final data = {
                'name': nameCtrl.text,
                'price': int.parse(priceCtrl.text),
              };

              if (id == null) {
                await db.insert('products', data);
              } else {
                await db.update(
                  'products',
                  data,
                  where: 'id = ?',
                  whereArgs: [id],
                );
              }

              Navigator.pop(context);
              loadProducts();
            },
            child: const Text('SIMPAN'),
          )
        ],
      ),
    );
  }

  void deleteProduct(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'products',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produk')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => saveProduct(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          return Card(
            child: ListTile(
              title: Text(p['name']),
              subtitle: Text(
                rupiah(p['price']),
                style: const TextStyle(
                  color: AppTheme.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => saveProduct(id: p['id']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteProduct(p['id']),
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
