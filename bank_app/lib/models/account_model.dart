class AccountModel {
  final int id;
  final String? first_name;
  final String? last_name;
  final String? fullName;
  final String email;
  final String? phone;
  final String accountNo;
  final double balance;

  AccountModel({
    required this.first_name,
    required this.last_name,
    required this.phone,
    required this.id,
    this.fullName,
    required this.email,
    required this.accountNo,
    required this.balance,
  });

  AccountModel copyWith({double? balance}) {
    return AccountModel(
      id: id,
      first_name: first_name,
      last_name: last_name,
      fullName: fullName,
      email: email,
      phone: phone,
      accountNo: accountNo,
      balance: balance ?? this.balance,
    );
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json["id"],
      first_name: json["first_name"],
      last_name: json["last_name"],
      fullName: json["fullname"],
      email: json["email"],
      phone: json["phone"],
      accountNo: json["accountNo"],
      balance: (json['balance'] is String)
          ? double.parse(json['balance'])
          : (json['balance'] as num).toDouble(),
    );
  }
}
