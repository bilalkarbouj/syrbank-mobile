import 'package:bank_app/features/profile/providers/profile_provider.dart';
import 'package:bank_app/features/profile/settings_pages/settings.dart';
import 'package:bank_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    print("🔥 ProfilePage initState çalıştı");
    Future.microtask(() {
      print("🔥 loadProfile çağrılıyor");
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final profileState = ref.watch(profileProvider);

    if (profileState.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profile = profileState.profile;

    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text("Profil bilgisi bulunamadı")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔷 ÜST PROFİL KARTI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: colorScheme.onPrimary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${profile.firstName} ${profile.lastName}",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔷 MENÜ
          Column(
            children: [
              const Divider(),

              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Settings()),
                ),
                child: _menuItem(icon: Icons.settings, title: "Ayarlar"),
              ),

              const SizedBox(height: 8),

              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.error.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_outlined,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Çıkış Yap",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuItem({required IconData icon, required String title}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
