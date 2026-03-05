import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Daha sağlıklı Provider tanımı
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadFromPrefs(); // Provider oluştuğu an hafızadan yükle
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool("isDarkMode") ?? false;
  }

  Future<void> toggleTheme(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDarkMode", value);
  }
}

// Uygulama açılırken temayı yükleyecek fonksiyon
Future<void> initTheme(WidgetRef ref) async {
  final isDark = await ThemeService.loadTheme();
  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
  ref.read(themeProvider.notifier).state = isDark;
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: "Roboto",
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
      brightness: Brightness.light,
      primary: const Color(0xFF1565C0),
      secondary: const Color(0xFF42A5F5),
    ),
    // Açık modda metinler varsayılan olarak koyu gelir
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF1565C0),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Color(0xFF1565C0)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,

      labelStyle: const TextStyle(color: Colors.black54),
      hintStyle: const TextStyle(color: Colors.black38),

      // INPUT İÇİNDEKİ YAZI
      floatingLabelStyle: const TextStyle(color: Color(0xFF1565C0)),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1565C0)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 50),
      ),
    ),

    // AppTheme içindeki darkTheme altına ekle:
    listTileTheme: const ListTileThemeData(
      tileColor: Colors.white,
      titleTextStyle: TextStyle(color: Colors.black87, fontSize: 16),
      subtitleTextStyle: TextStyle(color: Colors.black54, fontSize: 14),
      iconColor: Colors.black54,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(
      0xFF121212,
    ), // Standart dark mode rengi
    fontFamily: "Roboto",
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
      brightness: Brightness.dark, // Koyu mod renk paleti
      primary: const Color(0xFF1565C0),
      secondary: const Color(0xFF42A5F5),
      surface: const Color(
        0xFF1E1E1E,
      ), // Kartların ve kutuların rengi (Bir tık açık gri)
      onSurface: Colors.white, // Kart üzerindeki yazıların rengi
    ),
    // Koyu modda metinler otomatik olarak beyaz/açık gri olur
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),

    cardTheme: CardThemeData(
      color: Color(0xFF1E1E1E), // Koyu modda kart rengi
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white, // Koyu modda başlık beyaz olsun
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),

      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),

      floatingLabelStyle: const TextStyle(color: Color(0xFF42A5F5)),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF42A5F5)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 50),
      ),
    ),

    // AppTheme içindeki darkTheme altına ekle:
    listTileTheme: const ListTileThemeData(
      tileColor: Color(0xFF1E1E1E),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
      subtitleTextStyle: TextStyle(color: Colors.white70, fontSize: 14),
      iconColor: Colors.white70,
    ),
  );
}

class ThemeService {
  static const _key = "isDarkMode";

  // Temayı kaydet
  static Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
  }

  // Temayı oku
  static Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ??
        false; // Veri yoksa varsayılan olarak false (Açık mod)
  }
}
