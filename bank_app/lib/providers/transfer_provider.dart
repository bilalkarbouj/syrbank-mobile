import 'package:bank_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/transfer_request.dart';

enum TransferStatus { idle, loading, success, error }

class TransferState {
  final TransferStatus status;
  final String? error;
  final bool? receiverExists;

  const TransferState({
    this.status = TransferStatus.idle,
    this.error,
    this.receiverExists,
  });

  TransferState copyWith({
    TransferStatus? status,
    String? error,
    bool? receiverExists,
  }) {
    return TransferState(
      status: status ?? this.status,
      error: error,
      receiverExists: receiverExists ?? this.receiverExists,
    );
  }
}

class TransferNotifier extends StateNotifier<TransferState> {
  final Ref ref;

  TransferNotifier(this.ref) : super(const TransferState());

  void resetReceiver() {
    state = state.copyWith(receiverExists: null, error: null);
  }

  Future<void> reset() async {
    state = const TransferState();
  }

  Future<void> sendMoney(TransferRequest request) async {
    if (state.status == TransferStatus.loading) return;

    state = const TransferState(status: TransferStatus.loading);

    try {
      // 🔥 OPTIMISTIC UPDATE
      ref.read(authProvider.notifier).decreaseBalance(request.amount);

      final response = await ApiClient.post("/transfer", request.toJson());

      if (response.statusCode == 200) {
        await ref.read(authProvider.notifier).fetchAccount();
        state = const TransferState(status: TransferStatus.success);
      } else {
        // ❌ rollback ŞART
        ref.read(authProvider.notifier).rollbackBalance();

        state = const TransferState(
          status: TransferStatus.error,
          error: "Transfer failed",
        );
      }
    } catch (e) {
      ref.read(authProvider.notifier).rollbackBalance();
      state = TransferState(status: TransferStatus.error, error: e.toString());
    }
  }

  Future<void> checkReceiver(String accountNo) async {
    final cleanedAccountNo = accountNo.replaceAll(' ', '');
    try {
      final response = await ApiClient.get(
        "/transfer/check-account/$cleanedAccountNo",
      );

      if (response.statusCode == 200) {
        state = state.copyWith(
          receiverExists: true,
          status: TransferStatus.idle,
          error: null,
        );
      } else {
        state = state.copyWith(
          receiverExists: false,
          status: TransferStatus.idle,
          error: "Bu hesap numarası bulunamadı",
        );
      }
    } catch (_) {
      state = state.copyWith(
        receiverExists: false,
        status: TransferStatus.idle,
        error: "Alıcı kontrol edilemedi",
      );
    }
  }
}

final transferProvider = StateNotifierProvider<TransferNotifier, TransferState>(
  (ref) => TransferNotifier(ref),
);
