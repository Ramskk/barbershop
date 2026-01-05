class TransactionModel {
  final int? id;
  final int barberId;
  final int total;
  final String date;

  TransactionModel({
    this.id,
    required this.barberId,
    required this.total,
    required this.date,
  });
}
