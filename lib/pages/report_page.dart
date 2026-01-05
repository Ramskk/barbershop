import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../theme/app_theme.dart';

class ReportPage extends StatefulWidget {
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final currency = NumberFormat('#,##0', 'id_ID');

  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();

  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filtered = [];
  List<Map<String, dynamic>> capsters = [];

  String trxType = 'all';
  int? selectedCapsterId;

  String rupiah(int v) => 'Rp ${currency.format(v)}';

  String formatDate(String iso) {
    final d = DateTime.parse(iso);
    return DateFormat('dd MMM yyyy • HH:mm').format(d);
  }

  String toDateOnly(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    loadCapsters();
    loadReport();
  }

  Future<void> loadCapsters() async {
    final db = await DatabaseHelper.instance.database;
    capsters = await db.query(
      'capsters',
      where: 'is_active = 1',
      orderBy: 'name',
    );
    setState(() {});
  }

  Future<void> loadReport() async {
    final db = await DatabaseHelper.instance.database;

    reports = List<Map<String, dynamic>>.from(
      await db.rawQuery(
        '''
        SELECT
          t.id,
          t.date,
          t.capster_id,
          cap.name AS capster,
          cu.name AS customer,
          cu.phone AS phone,
          GROUP_CONCAT(ti.item_type) AS types,
          GROUP_CONCAT(
            ti.name || ' x' || ti.qty || ' = ' || ti.subtotal,
            char(10)
          ) AS items,
          t.total
        FROM transactions t
        LEFT JOIN capsters cap ON cap.id = t.capster_id
        JOIN transaction_customers tc ON tc.transaction_id = t.id
        JOIN customers cu ON cu.id = tc.customer_id
        JOIN transaction_items ti ON ti.transaction_id = t.id
        WHERE substr(t.date,1,10) BETWEEN ? AND ?
        GROUP BY t.id
        ORDER BY t.date DESC
        ''',
        [toDateOnly(startDate), toDateOnly(endDate)],
      ),
    );

    applyFilter();
  }

  void applyFilter() {
    filtered = reports.where((r) {
      if (selectedCapsterId != null &&
          r['capster_id'] != selectedCapsterId) return false;

      final types = (r['types'] as String).split(',');

      if (trxType == 'product' &&
          !(types.contains('product') && !types.contains('service'))) return false;
      if (trxType == 'service' &&
          !(types.contains('service') && !types.contains('product'))) return false;
      if (trxType == 'both' &&
          !(types.contains('service') && types.contains('product'))) return false;

      return true;
    }).toList();

    setState(() {});
  }

  Future<void> pickDate(bool start) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        start ? startDate = picked : endDate = picked;
      });
      loadReport();
    }
  }

  String trxLabel(List<String> types) {
    final hasService = types.contains('service');
    final hasProduct = types.contains('product');

    if (hasService && hasProduct) return 'Layanan + Produk';
    if (hasService) return 'Layanan';
    return 'Produk';
  }

  void showDetail(Map<String, dynamic> r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text('Detail Transaksi',
                  style: Theme.of(context).textTheme.titleLarge),

              const SizedBox(height: 16),

              _kv('Tanggal', formatDate(r['date'])),
              _kv('Customer', r['customer']),
              _kv('No HP', r['phone']),
              _kv('Capster', r['capster'] ?? 'Produk Only'),

              const Divider(height: 32),

              Text('Item',
                  style: Theme.of(context).textTheme.titleMedium),

              const SizedBox(height: 8),

              ...((r['items'] as String).split('\n')).map(
                    (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('• $e'),
                ),
              ),

              const Divider(height: 32),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  rupiah(r['total']),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(k)),
          const Text(':  '),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalOmzet =
    filtered.fold<int>(0, (s, e) => s + (e['total'] as int));

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Penjualan')),
      body: Column(
        children: [

          /// FILTER PANEL (FIX OVERFLOW)
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => pickDate(true),
                          child: Text('Dari: ${toDateOnly(startDate)}'),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => pickDate(false),
                          child: Text('Sampai: ${toDateOnly(endDate)}'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<int>(
                    value: selectedCapsterId,
                    hint: const Text('Semua Capster'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('Semua Capster'),
                      ),
                      ...capsters.map((c) => DropdownMenuItem<int>(
                        value: c['id'],
                        child: Text(c['name']),
                      )),
                    ],
                    onChanged: (v) {
                      selectedCapsterId = v;
                      applyFilter();
                    },
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: trxType,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Semua')),
                      DropdownMenuItem(value: 'product', child: Text('Produk Only')),
                      DropdownMenuItem(value: 'service', child: Text('Layanan Only')),
                      DropdownMenuItem(value: 'both', child: Text('Layanan + Produk')),
                    ],
                    onChanged: (v) {
                      trxType = v!;
                      applyFilter();
                    },
                  ),
                ],
              ),
            ),
          ),

          /// SUMMARY
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Transaksi: ${filtered.length}'),
                    Text(rupiah(totalOmzet),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gold,
                        )),
                  ],
                ),
              ),
            ),
          ),

          /// LIST
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final r = filtered[i];
                final types = (r['types'] as String).split(',');

                return ListTile(
                  onTap: () => showDetail(r),
                  title: Text('${r['customer']} • ${r['phone']}'),
                  subtitle: Text(
                    'Capster: ${r['capster'] ?? 'Produk Only'}  |  ${trxLabel(types)}\n'
                        '${formatDate(r['date'])}',
                  ),
                  trailing: Text(
                    rupiah(r['total']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.gold,
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
