import 'package:bank_app/models/transaction_model.dart';
import 'package:bank_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionCard extends ConsumerWidget {
  final TransactionModel tx;
  final int index;

  const TransactionCard({super.key, required this.tx, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final account = authState.account;

    if (account == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final accountNo = account.accountNo;
    var isOut = tx.fromAccount == accountNo;
    var datatime = DateFormat().format(tx.createdAt);
    final ispayment = tx.type == "payment";
    if (ispayment) {
      isOut = true;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Icon(
          !ispayment
              ? (isOut ? Icons.arrow_upward : Icons.arrow_downward)
              : Icons.payments,
          color: !ispayment
              ? isOut
                    ? Colors.red
                    : Colors.green
              : Colors.red,
        ),
        title: Text(
          isOut ? "Para Gönderildi" : "Para Alındı",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(datatime),
        trailing: Text(
          "${isOut ? '-' : '+'}${tx.amount.toStringAsFixed(2)} ₺",
          style: TextStyle(
            color: isOut ? Colors.red : Colors.green,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
