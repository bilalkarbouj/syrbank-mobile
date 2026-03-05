import 'package:bank_app/features/transfer/widgets/successSheet.dart';
import 'package:bank_app/providers/auth_provider.dart';
import 'package:bank_app/providers/transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transfer_request.dart';
import 'package:flutter/services.dart';

class TransferPage extends ConsumerStatefulWidget {
  final String? receiverAccount;
  final double? amount;
  final double? maxAmount;
  final String? description;

  const TransferPage({
    super.key,
    this.receiverAccount,
    this.amount,
    this.maxAmount,
    this.description,
  });

  @override
  ConsumerState<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends ConsumerState<TransferPage> {
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  double? _maxAmount;
  bool _amountLocked = false;

  @override
  void initState() {
    super.initState();

    if (widget.receiverAccount != null) {
      final raw = widget.receiverAccount!.replaceAll(' ', '');

      _accountController.text = widget.receiverAccount!;

      // 🔴 EN KRİTİK SATIR
      if (RegExp(r'^\d{16}$').hasMatch(raw)) {
        ref.read(transferProvider.notifier).checkReceiver(raw);
      }
    }

    if (widget.amount != null) {
      _amountController.text = widget.amount!.toStringAsFixed(2);
      _amountLocked = true; // 🔒 kilit
    }

    if (widget.maxAmount != null) {
      _maxAmount = widget.maxAmount;
    }

    if (widget.description != null) {
      _descriptionController.text = widget.description!;
    }

    _accountController.addListener(() {
      final raw = _accountController.text.replaceAll(' ', '');

      // TAM 16 HANE
      if (RegExp(r'^\d{16}$').hasMatch(raw)) {
        ref.read(transferProvider.notifier).checkReceiver(raw);
      }
    });

    _amountController.addListener(() => setState(() {}));
  }

  bool get _canSubmit {
    final acc = _accountController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText.replaceAll(',', '.'));

    return acc.isNotEmpty && amount != null && amount > 0;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(transferProvider, (previous, next) {
      // ✅ sadece transfer sonrası açılır
      if (previous?.status == TransferStatus.loading &&
          next.status == TransferStatus.success) {
        TransferSuccessSheet.show(
          ref: ref,
          context: context,
          receiverAccount: _accountController.text,
          amount: _amountController.text,
          description: _descriptionController.text,
        );
      }

      if (next.status == TransferStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error ?? "Transfer failed")),
        );
      }
    });

    final state = ref.watch(transferProvider);
    final authState = ref.watch(authProvider);
    final account = authState.account;

    if (account == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Para Transferi")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _inputAccount(
              state,
              "Alıcı Hesap No",
              _accountController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*([.,]\d{0,2})?$'),
                ),
                AccountNumberFormatter(),
              ],
            ),
            const SizedBox(height: 12),
            _input(
              "Tutar",
              _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*([.,]\d{0,2})?$'),
                ),
              ],
              enabled: !_amountLocked,
            ),
            if (_maxAmount != null)
              Text(
                "Maksimum tutar: ${_maxAmount!.toStringAsFixed(2)} ₺",
                style: const TextStyle(color: Colors.grey),
              ),

            const SizedBox(height: 12),
            _input("Açıklama", _descriptionController),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    (state.status == TransferStatus.loading || !_canSubmit)
                    ? null
                    : () {
                        final amountText = _amountController.text.trim();
                        final amount = double.tryParse(
                          amountText.replaceAll(',', '.'),
                        );

                        if (amount == null || amount <= 0) return;

                        // 🔒 MAX LIMIT KONTROLÜ
                        if (_maxAmount != null && amount > _maxAmount!) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Bu QR için maksimum tutar: ${_maxAmount!.toStringAsFixed(2)} ₺",
                              ),
                            ),
                          );
                          return;
                        }

                        final receiverExists = ref
                            .read(transferProvider)
                            .receiverExists;

                        if (receiverExists != true) {
                          // alıcı doğrulanmamışsa transferi durdur
                          return;
                        }

                        ref
                            .read(transferProvider.notifier)
                            .sendMoney(
                              TransferRequest(
                                toAccountNo: _accountController.text.trim(),
                                amount: amount,
                                description: _descriptionController.text.trim(),
                              ),
                            );
                      },

                child: state.status == TransferStatus.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Gönder"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController c, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      enabled: enabled,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        fillColor: enabled ? null : Colors.grey.shade100,
        filled: !enabled,
      ),
    );
  }
}

Widget _inputAccount(
  TransferState state,
  String label,
  TextEditingController _accountController, {
  bool isNumber = false,
  bool enabled = true, // enabled parametresini ekledik
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextField(
    controller: _accountController,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    enabled: enabled, // enabled durumunu burada kullanıyoruz
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      labelText: label,
      counterText: "",
      // _input fonksiyonundaki mantığın aynısı:
      fillColor: enabled ? null : Colors.grey.shade100,
      filled: !enabled,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      errorText: state.receiverExists == false
          ? "Bu hesap numarası bulunamadı"
          : null,
    ),
  );
}

class AccountNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 16) {
      return oldValue;
    }

    final buffer = StringBuffer();
    int selectIndex = newValue.selection.end;

    // ignore: unused_local_variable
    int usedSubstringLength = 0;
    for (int i = 0; i < digits.length; i++) {
      if (i % 4 == 0 && i != 0) {
        buffer.write(' ');
        usedSubstringLength++;
        if (i < newValue.text.length) {
          selectIndex++;
        }
      }
      buffer.write(digits[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: selectIndex),
    );
  }
}
