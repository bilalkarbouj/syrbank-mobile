import 'package:bank_app/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController phoneCtrl;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).profile;

    firstNameCtrl = TextEditingController(text: profile?.firstName ?? "");
    lastNameCtrl = TextEditingController(text: profile?.lastName ?? "");
    phoneCtrl = TextEditingController(text: profile?.phone ?? "");
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Profil Bilgileri"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 👤 PROFİL KARTI
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [ 
                const SizedBox(height: 16),
                _modernInput(
                  label: "Ad",
                  icon: Icons.person_outline,
                  controller: firstNameCtrl,
                ),
                const SizedBox(height: 16),
                _modernInput(
                  label: "Soyad",
                  icon: Icons.badge_outlined,
                  controller: lastNameCtrl,
                ),
                const SizedBox(height: 16),
                _phoneInput(controller: phoneCtrl),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 💾 KAYDET BUTONU
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: state.loading
                  ? null
                  : () async {
                      await ref
                          .read(profileProvider.notifier)
                          .saveProfile(
                            firstName: firstNameCtrl.text.trim(),
                            lastName: lastNameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim().isEmpty
                                ? null
                                : phoneCtrl.text.trim(),
                          );

                      if (mounted) Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: state.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Değişiklikleri Kaydet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 MODERN TEXT INPUT
  Widget _modernInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 📱 GELİŞMİŞ TELEFON INPUT
  Widget _phoneInput({required TextEditingController controller}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        // Sadece rakamlara izin ver
        FilteringTextInputFormatter.digitsOnly,
        // Maksimum 9 hane
        LengthLimitingTextInputFormatter(9),
      ],
      decoration: InputDecoration(
        labelText: "Telefon Numarası",
        hintText: "9XX XXX XXX",
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("🇸🇾", style: TextStyle(fontSize: 18)),
              SizedBox(width: 6),
              Text("+963"),
            ],
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
