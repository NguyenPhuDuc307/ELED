import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../services/csv_service.dart';
import '../../services/user_data_service.dart';
import '../../theme/brutalist_theme.dart';
import '../../widgets/section_header.dart';

/// Owns the CEFR level + topic filters that used to live inside the
/// notifications settings screen. These choices feed *every* word-picker
/// in the app — today's session, mini-games, notification scheduling —
/// so they belong in their own settings entry instead of being buried
/// under "Notifications".
class LearningPrefsSettingsScreen extends StatefulWidget {
  const LearningPrefsSettingsScreen({super.key});

  @override
  State<LearningPrefsSettingsScreen> createState() =>
      _LearningPrefsSettingsScreenState();
}

class _LearningPrefsSettingsScreenState
    extends State<LearningPrefsSettingsScreen> {
  static const _allLevels = ['A1', 'A2', 'B1', 'B2', 'C1'];

  List<String> _availableTopics = [];
  List<String> _selectedLevels = [];
  List<String> _selectedTopics = [];

  bool _isLoading = true;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final topics = await CsvService.getAvailableTopics();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _availableTopics = topics;
      _selectedLevels = prefs.getStringList('selectedPopularity') ??
          List.from(_allLevels);
      _selectedTopics = prefs.getStringList('selectedTopics') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedPopularity', _selectedLevels);
    await prefs.setStringList('selectedTopics', _selectedTopics);
    UserDataService().uploadSettings();
    if (!mounted) return;
    setState(() => _dirty = false);
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.learningPrefsTitle),
        actions: [
          TextButton(
            onPressed: _dirty ? _save : null,
            child: Text(
              t.commonSave,
              style: TextStyle(
                color: _dirty ? BrutalistTheme.primary : context.bMuted,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: context.bBorder, strokeWidth: 5),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    t.learningPrefsLevelsHeader,
                    subtitle: t.learningPrefsLevelsSubtitle,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allLevels.map(_buildLevelChip).toList(),
                  ),
                  const SizedBox(height: 32),
                  SectionHeader(
                    t.learningPrefsTopicsHeader,
                    subtitle: t.learningPrefsTopicsSubtitle,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableTopics.map(_buildTopicChip).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildLevelChip(String level) {
    final isSelected = _selectedLevels.contains(level);
    return FilterChip(
      label: Text(
        level,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? BrutalistTheme.white : context.bBorder,
        ),
      ),
      selected: isSelected,
      onSelected: (sel) {
        setState(() {
          if (sel) {
            _selectedLevels.add(level);
          } else {
            _selectedLevels.remove(level);
          }
        });
        _markDirty();
      },
      selectedColor: BrutalistTheme.primary,
      backgroundColor: context.bBg,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? BrutalistTheme.primary : context.bSubtle,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildTopicChip(String topic) {
    final isSelected = _selectedTopics.contains(topic);
    return FilterChip(
      label: Text(
        topic.replaceAll('_', ' '),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? BrutalistTheme.white : context.bBorder,
        ),
      ),
      selected: isSelected,
      onSelected: (sel) {
        setState(() {
          if (sel) {
            _selectedTopics.add(topic);
          } else {
            _selectedTopics.remove(topic);
          }
        });
        _markDirty();
      },
      selectedColor: BrutalistTheme.primary,
      backgroundColor: context.bBg,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? BrutalistTheme.primary : context.bSubtle,
          width: 1.5,
        ),
      ),
    );
  }
}
