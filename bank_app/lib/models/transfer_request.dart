class TransferRequest {
  final String toAccountNo;
  final double amount;
  final String? description;

  TransferRequest({
    required this.toAccountNo,
    required this.amount,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    "toAccountNo": toAccountNo.replaceAll(' ', ''),
    "amount": amount,
    "description": (description == null || description!.trim().isEmpty)
        ? "-"
        : description!.trim(),
  };
}
