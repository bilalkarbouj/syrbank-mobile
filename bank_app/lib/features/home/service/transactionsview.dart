import 'package:bank_app/features/home/widgets/transaction_card.dart';
import 'package:bank_app/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionProvider);
    final theme = Theme.of(context);

    if (state.status == TransactionStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == TransactionStatus.error) {
      return Center(child: Text(state.error ?? "Hata"));
    }

    if (state.transactions.isEmpty) {
      return Center(
        child: Text(
          "Henüz işlem yok",
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final tx in state.transactions)
          TransactionCard(tx: tx, index: state.transactions.indexOf(tx)),
      ],
    );
  }
}
