import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
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
                    const Icon(
                      Icons.person_add,
                      size: 60,
                      color: Color(0xFF1565C0),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Hesap Oluştur",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _inputField(
                      controller: _firstNameController,
                      hint: "İsim",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),

                    _inputField(
                      controller: _lastNameController,
                      hint: "Soyad",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),

                    _inputField(
                      controller: _emailController,
                      hint: "E-posta",
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),

                    _inputField(
                      controller: _passwordController,
                      hint: "Şifre",
                      icon: Icons.lock,
                      obscure: true,
                    ),

                    const SizedBox(height: 20),

                    if (authState.status == AuthStatus.error)
                      Text(
                        authState.errorMessage ?? "Kayıt başarısız oldu",
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
                                    .register(
                                      _firstNameController.text.trim(),
                                      _lastNameController.text.trim(),
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: authState.status == AuthStatus.loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Hesap Oluştur"),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () => {
                        ref.read(authProvider.notifier).goLogin(),
                      },
                      child: const Text(
                        "Daha önceden hesabınız var mı? Giriş yapın",
                      ),
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

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(
        color: Colors.black, // Devre dışıyken gri, aktifken tema rengi
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100, // Hafif gri, daha modern
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1565C0)),
        ),
      ),
    );
  }
}
