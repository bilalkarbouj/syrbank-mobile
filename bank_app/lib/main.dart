import 'package:bank_app/core/auth_guard.dart';
import 'package:bank_app/core/notification/local_notification_service.dart';
import 'package:bank_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Plugin init’i try/catch ile
  try {
    await LocalNotificationService.init();
  } catch (e, st) {
    debugPrint('Plugin init hatası: $e\n$st');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // Auth check
    Future.microtask(() async {
      await ref.read(authProvider.notifier).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    initTheme(ref);
    final isDarkMode = ref.watch(themeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // _isDark true ise koyu, false ise açık modu zorla
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AuthGateWithTokenCheck(), // Safe token check burada
    );
  }
}
