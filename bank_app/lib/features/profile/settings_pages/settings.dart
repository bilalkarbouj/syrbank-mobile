import 'package:bank_app/core/theme/app_theme.dart';
import 'package:bank_app/features/profile/settings_pages/ProfileEditePage.dart';
import 'package:bank_app/features/profile/settings_pages/change_password_page.dart';
import 'package:bank_app/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  bool _biometricEnabled = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = true;
  bool? _darkMode;
  Function(bool)? onThemeChanged;
  String _selectedLanguage = 'Türkçe';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ayarlar",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // KULLANICI PROFİLİ
          _settingsSection(
            title: "Hesap ve Profil",
            icon: Icons.person_outline,
            children: [
              _settingItem(
                title: "Profil Bilgileri",
                subtitle: "Ad, soyad, iletişim bilgileri",
                icon: Icons.edit_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileEditPage()),
                ),
              ),
              _settingItem(
                title: "Adres Bilgileri",
                subtitle: "Teslimat ve fatura adresleri",
                icon: Icons.location_on_outlined,
                onTap: () => _showComingSoon(context),
              ),
              _settingItem(
                title: "İletişim Tercihleri",
                subtitle: "SMS, e-posta, push bildirim",
                icon: Icons.notifications_outlined,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // GÜVENLİK AYARLARI
          _settingsSection(
            title: "Güvenlik",
            icon: Icons.security_outlined,
            children: [
              _settingItem(
                title: "Parola Değiştir",
                subtitle: "Uygulama şifrenizi güncelleyin",
                icon: Icons.lock_outline,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                ),
              ),
              _settingItem(
                title: "İki Adımlı Doğrulama",
                subtitle: "2FA (SMS, Authenticator)",
                icon: Icons.verified_user_outlined,
                onTap: () => _showComingSoon(context),
              ),
              _settingItem(
                title: "Oturum Yönetimi",
                subtitle: "Aktif cihazlar ve oturumlar",
                icon: Icons.devices_outlined,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // BİLDİRİM AYARLARI
          _settingsSection(
            title: "Bildirimler",
            icon: Icons.notifications_active,
            children: [
              SwitchListTile(
                title: Text(
                  "Push Bildirimler",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                subtitle: Text(
                  "Uygulama bildirimleri",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                secondary: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).iconTheme.color
,
                ),
                value: ref.watch(
                  notificationSettingsProvider,
                ), // Merkezi durumu dinle
                onChanged: (value) {
                  // Hem arayüzü hem hafızayı (SharedPreferences) günceller
                  ref.read(notificationSettingsProvider.notifier).toggle(value);
                },
                activeThumbColor: const Color(0xFF42A5F5),
              ),
              SwitchListTile(
                title: Text(
                  "E-posta Bildirimleri",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                subtitle: Text(
                  "İşlem bilgileri e-posta ile",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                secondary: Icon(
                  Icons.email_outlined,
                  color: Theme.of(context).iconTheme.color
,
                ),
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
                activeThumbColor: const Color(0xFF42A5F5),
              ),
              SwitchListTile(
                title: Text(
                  "SMS Bildirimleri",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                subtitle: Text(
                  "Önemli işlem SMS'leri",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                secondary: Icon(
                  Icons.sms_outlined,
                  color: Theme.of(context).iconTheme.color
,
                ),
                value: _smsNotifications,
                onChanged: (value) {
                  setState(() {
                    _smsNotifications = value;
                  });
                },
                activeThumbColor: const Color(0xFF42A5F5),
              ),
              _settingItem(
                title: "Bildirim Zamanları",
                subtitle: "Sessiz saatler ayarlayın",
                icon: Icons.access_time_outlined,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ÖDEME VE TRANSFER
          _settingsSection(
            title: "Ödeme ve Transfer",
            icon: Icons.payment_outlined,
            children: [
              _settingItem(
                title: "Havale Limitleri",
                subtitle: "Günlük/aylık limit ayarları",
                icon: Icons.payment_outlined,
                onTap: () => _showComingSoon(context),
              ),
              _settingItem(
                title: "Favori İşlemler",
                subtitle: "Sık kullanılan IBAN'lar",
                icon: Icons.star_border_outlined,
                onTap: () => _showComingSoon(context),
              ),
              _settingItem(
                title: "Otomatik Ödemeler",
                subtitle: "Düzenli ödeme talimatları",
                icon: Icons.autorenew_outlined,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // KART YÖNETİMİ
          _settingsSection(
            title: "Kartlarım",
            icon: Icons.credit_card_outlined,
            children: [
              _settingItem(
                title: "Sanal Kart Oluştur",
                subtitle: "Online alışveriş için",
                icon: Icons.sim_card_outlined,
                onTap: () => _showComingSoon(context),
              ),
              _settingItem(
                title: "Kart Limitleri",
                subtitle: "Alışveriş/nakit limit ayarı",
                icon: Icons.speed_outlined,
                onTap: () => _showComingSoon(context),
              ),
              _settingItem(
                title: "Kart Güvenliği",
                subtitle: "İnternet/işlem aç-kapa",
                icon: Icons.shield_outlined,
                onTap: () => _showComingSoon(context),
              ),
              _settingItem(
                title: "Kayıp/Çalıntı Bildir",
                subtitle: "Acil kart bloke etme",
                icon: Icons.report_problem_outlined,
                onTap: () => _showComingSoon(context),
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // UYGULAMA AYARLARI
          _settingsSection(
            title: "Uygulama",
            icon: Icons.settings_outlined,
            children: [
              SwitchListTile(
                title: Text(
                  "Koyu Tema",
                  style: TextStyle(
                    // Temadaki ana metin rengini otomatik çeker (Koyu modda beyaz olur)
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  "Arayüz temasını değiştir",
                  style: TextStyle(
                    // Temadaki alt metin rengini çeker (Koyu modda beyaz70 olur)
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 14,
                  ),
                ),
                secondary: Icon(
                  Icons.dark_mode_outlined,
                  // İkonun rengini de temaya bağlayalım
                  color: ref.watch(themeProvider)
                      ? Colors.amber
                      : Theme.of(context).iconTheme.color
,
                ),
                value: ref.watch(themeProvider), // O anki güncel durumu dinle
                onChanged: (bool newValue) {
                  // Merkezi durumu güncelle
                  ref.read(themeProvider.notifier).state = newValue;

                  ThemeService.saveTheme(newValue);

                  // Not: Riverpod kullandığında ayrıca setState(() {}) yazmana gerek kalmaz,
                  // çünkü ref.watch zaten widget'ı otomatik olarak günceller.
                },

                activeThumbColor: const Color(0xFF42A5F5),
              ),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text("Dil Seçeneği"),
                subtitle: Text(_selectedLanguage),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => _showLanguageDialog(context),
              ),
              _settingItem(
                title: "Ana Ekran Özelleştirme",
                subtitle: "Widget'lar ve hızlı erişim",
                icon: Icons.home_outlined,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // YARDIM VE DESTEK
          _settingsSection(
            title: "Yardım ve Destek",
            icon: Icons.help_outline_outlined,
            children: [
              _settingItem(
                title: "Sık Sorulan Sorular",
                subtitle: "SSS bölümüne gidin",
                icon: Icons.question_answer_outlined,
                onTap: () => _showComingSoon(context),
              ),
              _settingItem(
                title: "Canlı Destek",
                subtitle: "Chat veya telefon desteği",
                icon: Icons.support_agent_outlined,
                onTap: () => _showComingSoon(context),
              ),
              _settingItem(
                title: "Şube/Bankamatik Bul",
                subtitle: "Yakınınızdaki noktalar",
                icon: Icons.location_searching_outlined,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // VERİ VE GİZLİLİK
          _settingsSection(
            title: "Veri ve Gizlilik",
            icon: Icons.privacy_tip_outlined,
            children: [
              _settingItem(
                title: "Veri Kullanımı",
                subtitle: "Wi-Fi/Mobil data tercihi",
                icon: Icons.data_usage_outlined,
                onTap: () => _showComingSoon(context),
              ),
              _settingItem(
                title: "Gizlilik Ayarları",
                subtitle: "Veri paylaşım tercihleri",
                icon: Icons.visibility_off_outlined,
                onTap: () => _showComingSoon(context),
              ),
              _settingItem(
                title: "Hesap Ekstreleri",
                subtitle: "Eski kayıtları indirin",
                icon: Icons.description_outlined,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ÇIKIŞ BUTONU
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () => _showLogoutDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.shade200),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.exit_to_app_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Güvenli Çıkış Yap",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // UYGULAMA BİLGİSİ
          Center(
            child: Text(
              "Versiyon 1.0.0 • Build 1234",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // AYAR BÖLÜMÜ BAŞLIĞI
  Widget _settingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  // AYAR ÖĞESİ
  Widget _settingItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color:
              color?.withOpacity(0.7) ??
              Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 12,
        ),
      ),
      trailing: color == Colors.red
          ? const Icon(Icons.warning_outlined, color: Colors.red, size: 20)
          : const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // DİL SEÇİM DİYALOĞU
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dil Seçiniz"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption("Türkçe", "TR"),
            _languageOption("English", "EN"),
            _languageOption("Deutsch", "DE"),
            _languageOption("Français", "FR"),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(String language, String code) {
    return ListTile(
      title: Text(language),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      trailing: _selectedLanguage == language
          ? Icon(Icons.check, color: Theme.of(context).iconTheme.color
)
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Dil değiştirildi: $language"),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  // ÇIKIŞ DİYALOĞU
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text(
          "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Güvenli çıkış yapıldı"),
                  backgroundColor: Colors.green,
                ),
              );
              // Burada gerçek logout işlemi yapılacak
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Çıkış Yap",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // YAKINDA GELECEK MESAJI
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Bu özellik yakında gelecek!"),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
