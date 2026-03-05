// lib/features/profile/providers/change_password_provider.dart
import 'package:bank_app/core/network/api_client.dart';
import 'package:bank_app/core/storage/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final changePasswordProvider =
    StateNotifierProvider<ChangePasswordNotifier, bool>(
      (ref) => ChangePasswordNotifier(),
    );

class ChangePasswordNotifier extends StateNotifier<bool> {
  ChangePasswordNotifier() : super(false);

  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final token = await SecureStorage.getToken();
    if (token == null) return 'Token bulunamadı';

    state = true; // loading
    try {
      await ApiClient.post('/auth/change-password', {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      state = false; // loading bitti
      return null; // başarılı
    } catch (e) {
      state = false;
      return e.toString(); // hata mesajı
    }
  }
}
