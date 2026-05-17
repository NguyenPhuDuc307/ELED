import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../services/user_data_service.dart';
import '../../theme/brutalist_theme.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/section_header.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  String _themeMode = 'system';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _themeMode = prefs.getString('themeMode') ?? 'system');
  }

  Future<void> _select(String mode) async {
    setState(() => _themeMode = mode);
    EledApp.themeNotifier.value = mode == 'dark'
        ? ThemeMode.dark
        : mode == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode);
    UserDataService().uploadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              'Theme',
              subtitle: 'Choose a colour scheme. Changes apply instantly.',
            ),
            _themeTile('system', 'Match system', Icons.smartphone_rounded),
            _themeTile('light', 'Light', Icons.light_mode_rounded),
            _themeTile('dark', 'Dark', Icons.dark_mode_rounded),
          ],
        ),
      ),
    );
  }

  Widget _themeTile(String value, String label, IconData icon) {
    final selected = _themeMode == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BrutalistCard(
        backgroundColor: selected ? BrutalistTheme.accent : context.bBg,
        onTap: () => _select(value),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? BrutalistTheme.black : context.bBorder,
              ),
              const SizedBox(width: 14),
              Icon(icon,
                  color: selected ? BrutalistTheme.black : context.bBorder, size: 22),
              const SizedBox(width: 14),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? BrutalistTheme.black : context.bBorder,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
