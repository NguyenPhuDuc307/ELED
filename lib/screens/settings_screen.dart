import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../theme/brutalist_theme.dart';
import '../widgets/brutalist_card.dart';
import 'help_screen.dart';
import 'settings/about_screen.dart';
import 'settings/appearance_settings_screen.dart';
import 'settings/data_settings_screen.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _category(
              icon: Icons.notifications_active_rounded,
              title: 'Notifications',
              subtitle: _interval == 0
                  ? 'Off'
                  : 'Every $_interval ${_interval == 1 ? "minute" : "minutes"}',
              onTap: () async {
                await Navigator.of(context).push(
                  smoothRoute(const NotificationsSettingsScreen()),
                );
                _loadSummaries();
              },
            ),
            _category(
              icon: Icons.palette_rounded,
              title: 'Appearance',
              subtitle: _themeLabel(_themeMode),
              onTap: () async {
                await Navigator.of(context).push(
                  smoothRoute(const AppearanceSettingsScreen()),
                );
                _loadSummaries();
              },
            ),
            _category(
              icon: Icons.person_rounded,
              title: 'Account & data',
              subtitle: _user == null
                  ? 'Sign in, backup, share feedback'
                  : (_user!.email ?? 'Signed in'),
              onTap: () => Navigator.of(context).push(
                smoothRoute(const DataSettingsScreen()),
              ),
            ),
            _category(
              icon: Icons.help_outline_rounded,
              title: 'How to use',
              subtitle: 'Ratings, exercises, streaks — explained',
              onTap: () => Navigator.of(context).push(
                smoothRoute(const HelpScreen()),
              ),
            ),
            _category(
              icon: Icons.info_outline_rounded,
              title: 'About',
              subtitle: 'Version and updates',
              onTap: () => Navigator.of(context).push(
                smoothRoute(const AboutScreen()),
              ),
            ),
          ],
        ),
      ),
    );
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

  String _themeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'Match system';
    }
  }
}
