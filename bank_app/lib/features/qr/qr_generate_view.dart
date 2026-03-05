import 'dart:convert';
import 'package:bank_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerateView extends ConsumerStatefulWidget {
  const QRGenerateView({super.key});

  @override
  ConsumerState<QRGenerateView> createState() => _QRGenerateViewState();
}

class _QRGenerateViewState extends ConsumerState<QRGenerateView> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final accountNo = auth.account?.accountNo;

    var maxAmount = 5000.0; // Örnek maksimum tutar
    var description = "QR ile ödeme"; // Örnek açıklama
    final qrData = jsonEncode({
      "type": "qr_payment",
      "toAccount": accountNo,
      "maxAmount": maxAmount,
      "description": description,
      "createdAt": DateTime.now().toIso8601String(),
    });

    return Scaffold(
      appBar: AppBar(title: const Text("QR Oluştur"), centerTitle: true),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.1)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: qrData,
                size: 240,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                "QR ile Ödeme Al",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                "Max Tutar: 5.000 ₺",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
