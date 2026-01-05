import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../logic/cart_manager.dart';
import '../logic/transaction_service.dart';
import '../theme/app_theme.dart';

class TransactionPage extends StatefulWidget {
  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final CartManager cart = CartManager();
  final currency = NumberFormat('#,##0', 'id_ID');

  int? selectedCustomerId;
  int? selectedCapsterId;

  final TextEditingController customerSearchCtrl = TextEditingController();

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];
  List<Map<String, dynamic>> capsters = [];
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> products = [];

  String rupiah(int v) => 'Rp ${currency.format(v)}';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final db = await DatabaseHelper.instance.database;

    customers = await db.query('customers',
        where: 'is_active = 1', orderBy: 'name');
    filteredCustomers = List.from(customers);

    capsters = await db.query('capsters',
        where: 'is_active = 1', orderBy: 'name');

    services = await db.query('services',
        where: 'is_active = 1', orderBy: 'name');

    products = await db.query('products',
        where: 'is_active = 1', orderBy: 'name');

    setState(() {});
  }

  void searchCustomer(String keyword) {
    final key = keyword.toLowerCase();
    setState(() {
      filteredCustomers = customers.where((c) {
        return '${c['name']} ${c['phone']}'
            .toLowerCase()
            .contains(key);
      }).toList();
    });
  }

  CartItem? findProductItem(int productId) {
    try {
      return cart.items.firstWhere(
            (i) => i.type == 'product' && i.id == productId,
      );
    } catch (_) {
      return null;
    }
  }

  bool serviceSelected(int serviceId) {
    return cart.items.any(
          (i) => i.type == 'service' && i.id == serviceId,
    );
  }

  Future<void> saveTransaction() async {
    try {
      if (selectedCustomerId == null) {
        throw 'Customer wajib dipilih';
      }
      if (!cart.isValid) {
        throw 'Minimal 1 layanan atau produk wajib dipilih';
      }
      if (cart.hasService && selectedCapsterId == null) {
        throw 'Capster wajib dipilih jika ada layanan';
      }

      await TransactionService.saveTransactionReturnId(
        customerId: selectedCustomerId!,
        capsterId: cart.hasService ? selectedCapsterId : null,
        cart: cart,
      );

      cart.clear();
      selectedCapsterId = null;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget section(String title, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final capsterEnabled = cart.hasService;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// CUSTOMER
          section(
            'Customer',
            Column(
              children: [
                TextField(
                  controller: customerSearchCtrl,
                  decoration:
                  const InputDecoration(labelText: 'Cari nama / no HP'),
                  onChanged: searchCustomer,
                ),
                DropdownButton<int>(
                  isExpanded: true,
                  value: selectedCustomerId,
                  hint: const Text('Pilih Customer'),
                  items: filteredCustomers.map((c) {
                    return DropdownMenuItem<int>(
                      value: c['id'],
                      child: Text('${c['name']} - ${c['phone']}'),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setState(() => selectedCustomerId = v),
                ),
              ],
            ),
          ),

          /// CAPSTER
          section(
            'Capster',
            Opacity(
              opacity: capsterEnabled ? 1 : 0.4,
              child: IgnorePointer(
                ignoring: !capsterEnabled,
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: selectedCapsterId,
                  hint: const Text('Pilih Capster'),
                  items: capsters.map((c) {
                    return DropdownMenuItem<int>(
                      value: c['id'],
                      child: Text(c['name']),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setState(() => selectedCapsterId = v),
                ),
              ),
            ),
          ),

          /// LAYANAN (BISA BANYAK JENIS, QTY = 1)
          section(
            'Layanan',
            Column(
              children: services.map((s) {
                // ❗ CEK PER ID, BUKAN PER TYPE
                final bool selected = cart.items.any(
                      (i) => i.type == 'service' && i.id == s['id'],
                );

                return ListTile(
                  title: Text(s['name']),
                  subtitle: Text(rupiah(s['price'])),
                  trailing: IconButton(
                    icon: Icon(
                      selected ? Icons.check_circle : Icons.add_circle,
                      color: selected ? Colors.grey : AppTheme.gold,
                    ),
                    onPressed: selected
                        ? null // ❌ hanya disable service ini
                        : () => setState(() {
                      cart.addService(
                        s['id'],
                        s['name'],
                        s['price'],
                      );
                    }),
                  ),
                );
              }).toList(),
            ),
          ),


          /// PRODUK (QTY +/-)
          section(
            'Produk',
            Column(
              children: products.map((p) {
                final item = findProductItem(p['id']);

                return ListTile(
                  title: Text(p['name']),
                  subtitle: Text(rupiah(p['price'])),
                  trailing: item == null
                      ? IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() =>
                        cart.addProduct(
                          p['id'],
                          p['name'],
                          p['price'],
                        )),
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => setState(() {
                          if (item.qty > 1) {
                            item.qty--;
                          } else {
                            cart.removeItem(item);
                          }
                        }),
                      ),
                      Text(item.qty.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () =>
                            setState(() => item.qty++),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          /// RINGKASAN
          section(
            'Ringkasan',
            Column(
              children: cart.items.map((item) {
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                    '${rupiah(item.price)} x ${item.qty} = ${rupiah(item.subtotal)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        setState(() => cart.removeItem(item)),
                  ),
                );
              }).toList(),
            ),
          ),

          Card(
            color: AppTheme.card,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'TOTAL: ${rupiah(cart.total)}',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppTheme.gold),
              ),
            ),
          ),

          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: saveTransaction,
            child: const Text('SIMPAN TRANSAKSI'),
          ),
        ],
      ),
    );
  }
}
