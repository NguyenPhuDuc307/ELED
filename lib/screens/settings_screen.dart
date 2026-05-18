import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/gen/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import 'help_screen.dart';
import 'settings/about_screen.dart';
import 'settings/appearance_settings_screen.dart';
import 'settings/data_settings_screen.dart';
import 'settings/language_settings_screen.dart';
import 'settings/learning_prefs_settings_screen.dart';
import 'settings/notifications_settings_screen.dart';

/// Hub screen — surfaces a list of settings categories. Each row navigates to
/// its own focused sub-screen so users can find one thing at a time instead of
/// scrolling a long flat list.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? _user;
  int _interval = 60;
  String _themeMode = 'system';

  @override
  void initState() {
    super.initState();
    _user = AuthService().currentUser;
    AuthService().userStream.listen((u) {
      if (mounted) setState(() => _user = u);
    });
    _loadSummaries();
    LocaleService.notifier.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleService.notifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadSummaries() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _interval = prefs.getInt('notificationIntervalMinutes') ?? 60;
      _themeMode = prefs.getString('themeMode') ?? 'system';
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _category(
              icon: Icons.notifications_active_rounded,
              title: t.settingsNotifications,
              subtitle: _interval == 0
                  ? t.notificationsAll
                  : t.notificationsIntervalMinutes(_interval),
              onTap: () async {
                await Navigator.of(context).push(
                  smoothRoute(const NotificationsSettingsScreen()),
                );
                _loadSummaries();
              },
            ),
            _category(
              icon: Icons.palette_rounded,
              title: t.settingsAppearance,
              subtitle: _themeLabel(_themeMode, t),
              onTap: () async {
                await Navigator.of(context).push(
                  smoothRoute(const AppearanceSettingsScreen()),
                );
                _loadSummaries();
              },
            ),
            _category(
              icon: Icons.translate_rounded,
              title: t.settingsLanguage,
              subtitle: _languageLabel(t),
              onTap: () => Navigator.of(context).push(
                smoothRoute(const LanguageSettingsScreen()),
              ),
            ),
            _category(
              icon: Icons.tune_rounded,
              title: t.settingsLearningPrefs,
              subtitle: t.settingsLearningPrefsSubtitle,
              onTap: () => Navigator.of(context).push(
                smoothRoute(const LearningPrefsSettingsScreen()),
              ),
            ),
            _category(
              icon: Icons.person_rounded,
              title: t.settingsData,
              subtitle: _user == null
                  ? t.settingsDataSubtitle
                  : (_user!.email ?? t.settingsData),
              onTap: () => Navigator.of(context).push(
                smoothRoute(const DataSettingsScreen()),
              ),
            ),
            _category(
              icon: Icons.help_outline_rounded,
              title: t.helpTitle,
              subtitle: t.settingsAboutSubtitle,
              onTap: () => Navigator.of(context).push(
                smoothRoute(const HelpScreen()),
              ),
            ),
            _category(
              icon: Icons.info_outline_rounded,
              title: t.settingsAbout,
              subtitle: t.settingsAboutSubtitle,
              onTap: () => Navigator.of(context).push(
                smoothRoute(const AboutScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _languageLabel(AppLocalizations t) {
    final code = LocaleService.notifier.value?.languageCode;
    if (code == 'en') return t.languageEnglish;
    if (code == 'vi') return t.languageVietnamese;
    return t.languageSystem;
  }

  Widget _category({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return BrutalistCard(
      backgroundColor: context.bBg,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BrutalistTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: BrutalistTheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.bMuted,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.bMuted),
          ],
        ),
      ),
    );
  }

  String _themeLabel(String mode, AppLocalizations t) {
    switch (mode) {
      case 'light':
        return t.themeLight;
      case 'dark':
        return t.themeDark;
      default:
        return t.themeSystem;
    }
  }
}
