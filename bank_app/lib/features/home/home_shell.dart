import 'package:flutter/material.dart';
import 'package:bank_app/features/profile/profile_page.dart';
import 'package:bank_app/features/qr/qr_page.dart';
import 'package:bank_app/features/transfer/transfer_page.dart';
import 'home_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  /// 🔑 Dışarıdan State'e erişmek için
  static _HomeShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<_HomeShellState>();
  }

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  /// Sayfalar
  final List<Widget> _pages = const [
    HomePage(),
    TransferPage(),
    QrPage(),
    ProfilePage(),
  ];

  /// ✅ Anasayfaya dönmek için kullanılacak metod
  void goHome() {
    if (_currentIndex == 0) return; // gereksiz rebuild önlemi
    setState(() => _currentIndex = 0);
  }

  /// İstenirse dışarıdan başka indexlere de geçilebilir
  void changeTab(int index) {
    if (index < 0 || index >= _pages.length) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  spreadRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: changeTab,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFF1565C0),
              unselectedItemColor: Colors.grey.shade500,
              unselectedLabelStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),

              showUnselectedLabels: true,
              showSelectedLabels: true,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.swap_horiz_outlined),
                  activeIcon: Icon(Icons.swap_horiz_rounded),
                  label: "Transfer",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner_outlined),
                  activeIcon: Icon(Icons.qr_code_scanner_rounded),
                  label: "QR",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
