import 'package:flutter/material.dart';
import 'qr_generate_view.dart';
import 'qr_scan_view.dart';

class QrPage extends StatelessWidget {
  const QrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR İşlemleri")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card(
              context,
              icon: Icons.qr_code,

              title: "QR ile Ödeme Al",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRGenerateView()),
              ),
            ),
            const SizedBox(height: 16),
            _card(
              context,
              icon: Icons.qr_code_scanner,
              title: "QR ile Ödeme Yap",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRScanView()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.08)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.black),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
