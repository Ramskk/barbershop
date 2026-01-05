import '../db/database_helper.dart';
import 'cart_manager.dart';

class TransactionService {
  static Future<int> saveTransactionReturnId({
    required int customerId,
    int? capsterId,
    required CartManager cart,
  }) async {

    if (!cart.isValid) {
      throw Exception('Minimal 1 layanan atau produk wajib dipilih');
    }

    if (cart.hasService && capsterId == null) {
      throw Exception('Capster wajib dipilih jika ada layanan');
    }

    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();

    final trxCode =
        'TRX-${now.year}${now.month.toString().padLeft(2, '0')}-${now.microsecondsSinceEpoch}';

    final trxId = await db.insert('transactions', {
      'trx_code': trxCode,
      'capster_id': capsterId,
      'total': cart.total,
      'date': now.toIso8601String(),
    });

    await db.insert('transaction_customers', {
      'transaction_id': trxId,
      'customer_id': customerId,
    });

    for (final item in cart.items) {
      await db.insert('transaction_items', {
        'transaction_id': trxId,
        'item_type': item.type,
        'item_id': item.id,
        'name': item.name,
        'price': item.price,
        'qty': item.qty,
        'subtotal': item.subtotal,
      });
    }

    return trxId;
  }
}
