import 'dart:convert';
import 'package:bank_app/core/network/api_client.dart';
import 'package:bank_app/features/profile/model/profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileService {
  final ApiClient _api;
  ProfileService(this._api);

  Future<ProfileModel> fetchProfile() async {
    print("🌐 /me isteği atılıyor");

    final res = await ApiClient.get("/auth/me");

    print("🌐 statusCode: ${res.statusCode}");
    print("🌐 body: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Profil alınamadı");
    }

    final data = jsonDecode(res.body);
    return ProfileModel.fromJson(data);
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final res = await ApiClient.post("/user/updateprofile", {
      "first_name": firstName,
      "last_name": lastName,
      "phone": phone,
    });

    if (res.statusCode != 200) {
      throw Exception("Profil güncellenemedi");
    }
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  final api = ref.read(apiClientProvider);
  return ProfileService(api);
});
