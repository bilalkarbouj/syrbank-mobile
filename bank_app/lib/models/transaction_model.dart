class TransactionModel {
  final int id;
  final String fromAccount;
  final String toAccount;
  final double amount;
  final String description;
  final String type;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.fromAccount,
    required this.toAccount,
    required this.amount,
    required this.description,
    required this.type,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      fromAccount: json['from_account'],
      toAccount: json['to_account'],
      amount: double.parse(json['amount'].toString()),
      description: json['description'] ?? "-",
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
