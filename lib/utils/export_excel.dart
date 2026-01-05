import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path/path.dart';

class ExportExcel {
  static Future<String> exportReport(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) {
      throw Exception('Tidak ada data untuk diexport');
    }

    final excel = Excel.createExcel();
    final sheet = excel['Laporan'];

    /// HEADER
    sheet.appendRow([
      TextCellValue('Tanggal'),
      TextCellValue('Capster'),
      TextCellValue('Customer'),
      TextCellValue('No HP'),
      TextCellValue('Detail'),
      TextCellValue('Total'),
    ]);

    /// DATA
    for (final r in data) {
      sheet.appendRow([
        TextCellValue(r['date'].toString()),
        TextCellValue(r['capster'] ?? 'Produk Only'),
        TextCellValue(r['customer'].toString()),
        TextCellValue(r['phone'].toString()),
        TextCellValue((r['items'] ?? '').toString()),
        IntCellValue((r['total'] ?? 0) as int),
      ]);
    }

    /// FOLDER DOWNLOAD
    final dir = Directory('/storage/emulated/0/Download/HexaBarbershop');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final now = DateTime.now();
    final fileName =
        'laporan_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}.xlsx';

    final filePath = join(dir.path, fileName);

    final fileBytes = excel.encode();
    if (fileBytes == null) {
      throw Exception('Gagal generate Excel');
    }

    final file = File(filePath);
    await file.writeAsBytes(fileBytes, flush: true);

    return filePath;
  }
}
