class ProfileModel {
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;

  ProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    print("🧩 JSON PARSE => $json");
    return ProfileModel(
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"], // null olabilir
    );
  }
}
