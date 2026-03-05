import 'dart:convert';

import 'package:bank_app/models/transaction_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

enum TransactionStatus { idle, loading, success, error }

class TransactionState {
  final TransactionStatus status;
  final List<TransactionModel> transactions;
  final String? error;

  const TransactionState({
    this.status = TransactionStatus.idle,
    this.transactions = const [],
    this.error,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionModel>? transactions,
    String? error,
    bool? receiverExists,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      error: error,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier() : super(const TransactionState());

  Future<void> fetchTransactions() async {
    state = state.copyWith(status: TransactionStatus.loading);

    try {
      final response = await ApiClient.get("/transactions");

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);

        final transactions = list
            .map((e) => TransactionModel.fromJson(e))
            .toList();

        state = state.copyWith(
          status: TransactionStatus.success,
          transactions: transactions,
        );
      } else {
        state = state.copyWith(
          status: TransactionStatus.error,
          error: "İşlemler alınamadı",
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: TransactionStatus.error,
        error: e.toString(),
      );
    }
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      final notifier = TransactionNotifier();
      notifier.fetchTransactions();
      return notifier;
    });
