import 'package:bank_app/features/auth/register/register_page.dart';
import 'package:bank_app/features/home/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/login/login_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // ⏳ Splash / Loading
    if (authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ✅ Giriş yapılmışsa
    if (authState.status == AuthStatus.authenticated) {
      return const HomeShell();
    }

    // ❌ Giriş yapılmamışsa → FLOW kontrolü
    if (authState.status == AuthStatus.unauthenticated) {
      if (authState.flow == AuthFlow.register) {
        return const RegisterPage();
      }
      return const LoginPage(); // default
    }

    // ⚠️ Error
    return const LoginPage();
  }
}
