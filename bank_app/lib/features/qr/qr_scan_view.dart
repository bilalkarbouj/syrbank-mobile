import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../features/transfer/transfer_page.dart';

class QRScanView extends StatefulWidget {
  const QRScanView({super.key});

  @override
  State<QRScanView> createState() => _QRScanViewState();
}

class _QRScanViewState extends State<QRScanView> {
  bool _handled = false;

  void _handleQR(String raw) {
    if (_handled) return;
    _handled = true;

    try {
      final data = jsonDecode(raw);

      if (data["type"] != "qr_payment") {
        throw "Geçersiz QR";
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TransferPage(
            receiverAccount: data["toAccount"],
            maxAmount: data["maxAmount"],
            description: data["description"],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Geçersiz QR kod")));
      _handled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Okut")),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          if (barcode.rawValue != null) {
            _handleQR(barcode.rawValue!);
          }
        },
      ),
    );
  }
}
