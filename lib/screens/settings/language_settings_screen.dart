import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../services/locale_service.dart';
import '../../theme/brutalist_theme.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/section_header.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  Future<void> _select(Locale? locale) async {
    await LocaleService.set(locale);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final current = LocaleService.notifier.value;

    return Scaffold(
      appBar: AppBar(title: Text(t.languageSettingTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              t.languageSettingTitle,
              subtitle: t.languageSettingSubtitle,
            ),
            _tile(null, t.languageSystem, Icons.smartphone_rounded, current),
            _tile(const Locale('en'), t.languageEnglish, Icons.translate_rounded, current),
            _tile(const Locale('vi'), t.languageVietnamese, Icons.translate_rounded, current),
          ],
        ),
      ),
    );
  }

  Widget _tile(Locale? value, String label, IconData icon, Locale? current) {
    final selected = value?.languageCode == current?.languageCode;
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
