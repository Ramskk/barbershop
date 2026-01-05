import '../db/database_helper.dart';

class ReportService {
  static Future<List<Map<String, dynamic>>> fetchReport({
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await DatabaseHelper.instance.database;

    return await db.rawQuery('''
      SELECT
        t.id,
        t.trx_code,
        t.date,
        t.total,
        c.name AS customer_name,
        c.phone AS customer_phone,
        cp.name AS capster_name
      FROM transactions t
      JOIN transaction_customers tc
        ON tc.transaction_id = t.id
      JOIN customers c
        ON c.id = tc.customer_id
      LEFT JOIN capsters cp
        ON cp.id = t.capster_id
      WHERE date(t.date) BETWEEN date(?) AND date(?)
      ORDER BY t.date DESC
    ''', [
      start.toIso8601String(),
      end.toIso8601String(),
    ]);
  }
}
