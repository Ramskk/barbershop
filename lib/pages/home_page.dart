import 'package:flutter/material.dart';

import 'transaction_page.dart';
import 'report_page.dart';
import 'customer_page.dart';
import 'capster_page.dart';
import 'service_page.dart';
import 'product_page.dart';
import 'account_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hexa Barbershop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Operasional'),
          _menu(context, Icons.point_of_sale, 'Transaksi', TransactionPage()),
          _menu(context, Icons.bar_chart, 'Laporan', ReportPage()),

          const SizedBox(height: 20),
          _section('Master Data'),
          _menu(context, Icons.people_outline, 'Customer', CustomerPage()),
          _menu(context, Icons.person_outline, 'Capster', CapsterPage()),
          _menu(context, Icons.design_services, 'Layanan', ServicePage()),
          _menu(context, Icons.inventory_2_outlined, 'Produk', ProductPage()),

          const SizedBox(height: 20),
          _section('Akun'),
          _menu(context, Icons.admin_panel_settings, 'Akun Admin', AccountPage()),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                    (_) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _menu(
      BuildContext context,
      IconData icon,
      String title,
      Widget page,
      ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        ),
      ),
    );
  }
}
