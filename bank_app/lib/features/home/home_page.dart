import 'package:bank_app/features/home/home_shell.dart';
import 'package:bank_app/features/home/notifications_page.dart';
import 'package:bank_app/features/home/service/transactionsview.dart';

import 'package:bank_app/providers/auth_provider.dart';
import 'package:bank_app/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final ProviderSubscription _notificationSub;

  @override
  void initState() {
    super.initState();

    _notificationSub = ref.listenManual<List<NotificationData>>(
      notificationListProvider,
      (previous, next) async {
        // Eğer yeni gelen liste boşsa veya öncekiyle aynı boyuttaysa işlem yapma
        if (next.isEmpty ||
            (previous != null && next.length <= previous.length))
          return;

        // Listenin en başındaki (en son eklenen) bildirimi al
        final lastNotification = next.first;

        // 🟢 Ekranın alt kısmında SnackBar göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text(lastNotification.message)),
              ],
            ),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: "GÖR",
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _notificationSub.close();
    super.dispose();
  }

  bool _isBalanceVisible = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final account = authState.account;

    if (account == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userName = account.first_name;
    final accountNo = account.accountNo;
    final balance = account.balance;

    final theme = Theme.of(context);

    final currencyFormatter = NumberFormat.currency(
      locale: 'ar',
      symbol: '₺',
      decimalDigits: 2,
    );

    // Mock (sonra provider’dan bağlanır)

    return Scaffold(
      appBar: AppBar(
        title: const Text("SYRBANK"),
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              // Okunmamış bildirim sayısını dinle
              final unreadCount = ref
                  .watch(notificationListProvider.notifier)
                  .unreadCount;

              return Badge(
                label: Text(unreadCount.toString()),
                isLabelVisible: unreadCount > 0, // 0 ise rozeti gizle
                backgroundColor: Colors.red,
                child: IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {
                    // Bildirimler sayfasına git
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8), // Sağdan biraz boşluk
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// HEADER CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hoşgeldin, $userName!",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Hesap Numarası,",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "SYR${accountNo}",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 16),

                /// BALANCE CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Toplam Bakiye",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isBalanceVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isBalanceVisible = !_isBalanceVisible;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isBalanceVisible
                            ? currencyFormatter.format(balance)
                            : "********",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Hızlı İşlemler",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _modernQuickAction(
                        context,
                        onTap: () => HomeShell.of(context)?.changeTab(1),
                        title: "Transfer",
                        subtitle: "Para gönder",
                        icon: Icons.swap_horiz_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                        ),
                      ),
                      _modernQuickAction(
                        context,
                        onTap: () => HomeShell.of(context)?.changeTab(2),
                        title: "Ödeme",
                        subtitle: "Fatura & QR",
                        icon: Icons.qr_code_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
                        ),
                      ),
                      _modernQuickAction(
                        context,
                        onTap: () async => _copyToClipboard(context, accountNo),
                        title: "IBAN",
                        subtitle: "Kopyala",
                        icon: Icons.copy_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// SON İŞLEMLER
          Text(
            "Son İşlemler",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          TransactionsView(),
        ],
      ),
    );
  }
}

void _copyToClipboard(BuildContext context, String text) async {
  try {
    if (text.isEmpty) {
      throw Exception("Kopyalanacak metin boş.");
    }

    await Clipboard.setData(ClipboardData(text: text));

    // Başarı mesajı (context null olabilir diye kontrol)
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("IBAN kopyalandı"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kopyalama başarısız: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Widget _modernQuickAction(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
  required Gradient gradient,
  required GestureTapCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
