import 'dart:async';
import 'package:bank_app/models/account_model.dart';
import 'package:bank_app/providers/notification_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

enum AuthFlow { login, register }

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AuthFlow? flow;
  final String? errorMessage;
  final AccountModel? account;
  final double? previousBalance;

  const AuthState({
    required this.status,
    this.flow,
    this.errorMessage,
    this.account,
    this.previousBalance,
  });
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  AuthState copyWith({
    AuthStatus? status,
    AuthFlow? flow,
    String? errorMessage,
    AccountModel? account,
    double? previousBalance,
  }) {
    return AuthState(
      status: status ?? this.status,
      flow: flow ?? this.flow,
      errorMessage: errorMessage ?? this.errorMessage,
      account: account ?? this.account,
      previousBalance: previousBalance ?? this.previousBalance,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  AuthNotifier(this.ref) : super(AuthState.initial());

  /// 📝 REGISTER
  Future<void> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      final response = await ApiClient.post("/auth/register", {
        "fullName": "$firstName $lastName",
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      } else {
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: "Registration failed",
        );
      }
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  /// 🔐 TOKEN KONTROL
  Future<void> checkAuth() async {
    final token = await SecureStorage.getToken();

    if (token == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    state = const AuthState(status: AuthStatus.authenticated);

    try {
      final response = await ApiClient.get("/auth/me");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = state.copyWith(account: AccountModel.fromJson(data));
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// 🔑 LOGIN
  Future<void> login(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      final response = await ApiClient.post("/auth/login", {
        "email": email,
        "password": password,
      });
      print("📩 Login response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Login successful, token: ${data["accessToken"]}");

        // 1️⃣ token kaydet
        await SecureStorage.saveToken(data["accessToken"]);

        // 2️⃣ authenticated yap
        state = state.copyWith(status: AuthStatus.authenticated);

        // 3️⃣ user bilgisini çek
        await fetchAccount();

        // 4️⃣ socket BAĞLA (DOĞRU YER)
        final account = state.account!;
        final token = await SecureStorage.getToken();

        ref
            .read(socketServiceProvider)
            .connect(accountNo: account.accountNo.toString(), token: token!);

        await Permission.notification.request();
      } else {
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: "Login failed",
        );
      }
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    // stopBalanceListener();
    await SecureStorage.deleteToken();
    ref.read(socketServiceProvider).disconnect();

    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// 🚪 Go Register
  void goRegister() {
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      flow: AuthFlow.register,
    );
  }

  /// 🚪 GO LOGIN
  void goLogin() {
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      flow: AuthFlow.login,
    );
  }

  Future<void> fetchAccount() async {
    final response = await ApiClient.get("/auth/me");
    if (response.statusCode == 200) {
      state = state.copyWith(
        account: AccountModel.fromJson(jsonDecode(response.body)),
      );
    }
  }

  void decreaseBalance(double amount) {
    if (state.account == null) return;
    state = state.copyWith(
      previousBalance: state.account!.balance,
      account: state.account!.copyWith(
        balance: state.account!.balance - amount,
      ),
    );
  }

  void rollbackBalance() {
    if (state.previousBalance == null || state.account == null) return;
    state = state.copyWith(
      account: state.account!.copyWith(balance: state.previousBalance!),
      previousBalance: null,
    );
  }

  void commitBalance() {
    state = state.copyWith(previousBalance: null);
  }

  void updateBalanceFromSocket(double newBalance) {
    if (state.account == null) return;

    // Eğer optimistic işlem varsa, socket overwrite ETMESİN
    if (state.previousBalance != null) return;

    state = state.copyWith(
      account: state.account!.copyWith(balance: newBalance),
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
