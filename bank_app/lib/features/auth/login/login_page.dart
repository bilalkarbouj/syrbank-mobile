import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5), Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: Colors.white,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "SYRIA BANK",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 36,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Tek bir adımda finansal özgürlüğe ulaşın",
                      style: TextStyle(
                        color:
                            Theme.of(context).dialogTheme.titleTextStyle?.color
                                ?.withOpacity(0.7) ??
                            Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      controller: _emailController,
                      style: TextStyle(
                        color: Colors
                            .black, // Devre dışıyken gri, aktifken tema rengi
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Colors.grey.shade100, // Hafif gri, daha modern
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        hintText: "E-posta",
                        prefixIcon: const Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      // Yazı rengini buradan ayarlıyoruz:
                      style: TextStyle(
                        color: Colors
                            .black, // Devre dışıyken gri, aktifken tema rengi
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Colors.grey.shade100, // Hafif gri, daha modern
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Color(0xFF1565C0)),
                        ),
                        hintText: "Şifre",
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (authState.status == AuthStatus.error)
                      Text(
                        authState.errorMessage ?? "Login error",
                        style: const TextStyle(color: Colors.red),
                      ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authState.status == AuthStatus.loading
                            ? null
                            : () {
                                ref
                                    .read(authProvider.notifier)
                                    .login(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                              },
                        child: authState.status == AuthStatus.loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Giriş Yap"),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        ref.read(authProvider.notifier).goRegister();
                      },
                      child: const Text("Hesap Oluştur"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
