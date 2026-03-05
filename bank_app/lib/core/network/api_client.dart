import 'dart:convert';
import 'package:bank_app/core/config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  static const String baseUrl = AppConfig.apiBaseUrl;
  // Android emulator için

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await SecureStorage.getToken();

    return http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String path) async {
    final token = await SecureStorage.getToken();
    print("🔑 TOKEN: $token");

    return http.get(
      Uri.parse(baseUrl + path),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }
}
