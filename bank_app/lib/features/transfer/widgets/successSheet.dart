import 'package:bank_app/features/home/home_shell.dart';
import 'package:bank_app/features/transfer/service/recepit_service.dart';
import 'package:bank_app/providers/transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransferSuccessSheet {
  static void show({
    required BuildContext context,
    required WidgetRef ref,
    required String receiverAccount,
    required String amount,
    required String description,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 12),
              const Text(
                "Transfer Başarılı",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              _infoRow("Alıcı Hesap", receiverAccount),
              _infoRow("Tutar", "$amount ₺"),
              _infoRow("Açıklama", description.isEmpty ? "-" : description),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long),
                label: const Text("Dekont Oluştur"),
                onPressed: () async {
                  final pdf = await ReceiptService.generate(
                    senderName: "Bilal Karbouj",
                    receiverAccount: receiverAccount,
                    amount: amount,
                    description: description,
                  );

                  await Printing.layoutPdf(onLayout: (_) => pdf);
                },
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  // 1) BottomSheet kapatılıyor
                  Navigator.pop(context);

                  // 2) Transfer state sıfırlanıyor
                  ref.read(transferProvider.notifier).reset();

                  // 3) Ana sayfaya dönülüyor
                  HomeShell.of(context)?.goHome();
                },
                child: const Text("Ana Sayfaya Dön"),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
