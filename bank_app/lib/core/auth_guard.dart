import 'dart:io';
import 'package:bank_app/core/navigation/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'storage/secure_storage.dart';

class AuthGuard {
  static Future<void> checkTokenAndHandle(BuildContext context) async {
    final token = await SecureStorage.getToken();

    if (token == null || JwtDecoder.isExpired(token)) {
      // Token yok veya süresi dolmuş
      if (!context.mounted) return; // widget destroy olmuşsa dialog açma

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Oturum Süresi Doldu"),
          content: const Text("Lütfen tekrar giriş yapın."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (Platform.isAndroid) {
                  SystemNavigator.pop();
                } else if (Platform.isIOS) {
                  exit(0);
                }
              },
              child: const Text("Tamam"),
            ),
          ],
        ),
      );
    }
  }
}

// ===================== AuthGate Wrapper =====================
class AuthGateWithTokenCheck extends ConsumerStatefulWidget {
  const AuthGateWithTokenCheck({super.key});

  @override
  ConsumerState<AuthGateWithTokenCheck> createState() =>
      _AuthGateWithTokenCheckState();
}

class _AuthGateWithTokenCheckState
    extends ConsumerState<AuthGateWithTokenCheck> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await SecureStorage.getToken();
      final loggedIn = token != null && !JwtDecoder.isExpired(token);

      if (loggedIn) {
        await AuthGuard.checkTokenAndHandle(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const AuthGate();
  }
}
