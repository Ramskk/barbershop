import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';

class ReportPage extends StatefulWidget {
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final currency = NumberFormat('#,##0', 'id_ID');

  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();

  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> capsterSummary = [];

  String rupiah(int value) => 'Rp ${currency.format(value)}';

  String dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  Future<void> loadReport() async {
    final db = await DatabaseHelper.instance.database;
    final start = dateOnly(startDate);
    final end = dateOnly(endDate);

    /// LAPORAN TRANSAKSI
    reports = List<Map<String, dynamic>>.from(
      await db.rawQuery('''
        SELECT
          t.trx_code,
          t.date,
          cap.name AS capster,
          cu.name AS customer,
          cu.phone AS phone,
          GROUP_CONCAT(
            ti.name || ' x' || ti.qty || ' = ' || ti.subtotal,
            char(10)
          ) AS items,
          t.total
        FROM transactions t
        JOIN capsters cap ON cap.id = t.capster_id
        JOIN transaction_customers tc ON tc.transaction_id = t.id
        JOIN customers cu ON cu.id = tc.customer_id
        JOIN transaction_items ti ON ti.transaction_id = t.id
        WHERE substr(t.date,1,10) BETWEEN ? AND ?
        GROUP BY t.id
        ORDER BY t.date DESC
      ''', [start, end]),
    );

    /// LAPORAN PER CAPSTER
    capsterSummary = List<Map<String, dynamic>>.from(
      await db.rawQuery('''
        SELECT
          cap.name AS capster,
          COUNT(t.id) total_trx,
          SUM(t.total) omzet
        FROM transactions t
        JOIN capsters cap ON cap.id = t.capster_id
        WHERE substr(t.date,1,10) BETWEEN ? AND ?
        GROUP BY cap.id
        ORDER BY omzet DESC
      ''', [start, end]),
    );

    setState(() {});
  }

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        isStart ? startDate = picked : endDate = picked;
      });
      loadReport();
    }
  }

  Widget itemCell(String raw) {
    final formatted = raw
        .split('\n')
        .map((e) => e.replaceAllMapped(
      RegExp(r'=(\s*)(\d+)'),
          (m) => '= ${rupiah(int.parse(m[2]!))}',
    ))
        .join('\n');

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 260,
        minHeight: 56,
        maxHeight: 140,
      ),
      child: SingleChildScrollView(
        child: Text(
          formatted,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Penjualan')),
      body: Column(
        children: [

          /// FILTER TANGGAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () => pickDate(true),
                child: Text('Dari: ${dateOnly(startDate)}'),
              ),
              TextButton(
                onPressed: () => pickDate(false),
                child: Text('Sampai: ${dateOnly(endDate)}'),
              ),
            ],
          ),

          /// TABEL TRANSAKSI
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowMinHeight: 56,
                dataRowMaxHeight: 160,
                columns: const [
                  DataColumn(label: Text('Tanggal')),
                  DataColumn(label: Text('Kode')),
                  DataColumn(label: Text('Capster')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('No HP')),
                  DataColumn(label: Text('Layanan / Produk')),
                  DataColumn(label: Text('Total')),
                ],
                rows: reports.map((r) {
                  return DataRow(cells: [
                    DataCell(Text(r['date'].substring(0, 10))),
                    DataCell(Text(r['trx_code'])),
                    DataCell(Text(r['capster'])),
                    DataCell(Text(r['customer'])),
                    DataCell(Text(r['phone'])),
                    DataCell(itemCell(r['items'] ?? '')),
                    DataCell(Text(rupiah(r['total']))),
                  ]);
                }).toList(),
              ),
            ),
          ),

          const Divider(),

          /// LAPORAN PER CAPSTER
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Ringkasan Per Capster',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Capster')),
                DataColumn(label: Text('Total Transaksi')),
                DataColumn(label: Text('Omzet')),
              ],
              rows: capsterSummary.map((c) {
                return DataRow(cells: [
                  DataCell(Text(c['capster'])),
                  DataCell(Text(c['total_trx'].toString())),
                  DataCell(Text(rupiah(c['omzet']))),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
