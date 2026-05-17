import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/vocabulary.dart';
import '../../services/csv_service.dart';
import '../../services/notification_service.dart';
import '../../services/user_data_service.dart';
import '../../theme/brutalist_theme.dart';
import '../../widgets/brutalist_card.dart';
import '../../widgets/section_header.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  int _intervalMinutes = 60;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 19, minute: 0);

  List<String> _availableTopics = [];
  List<String> _selectedPopularity = [];
  List<String> _selectedTopics = [];

  bool _isLoading = true;
  bool _isSaving = false;
  bool _dirty = false;
  bool _batteryUnrestricted = true;

  static const _allPopularityLevels = ['A1', 'A2', 'B1', 'B2', 'C1'];

  @override
  void initState() {
    super.initState();
    _load();
    _refreshBatteryStatus();
  }

  Future<void> _refreshBatteryStatus() async {
    if (!Platform.isAndroid) return;
    final ok = await NotificationService().isIgnoringBatteryOptimizations();
    if (mounted) setState(() => _batteryUnrestricted = ok);
  }

  Future<void> _load() async {
    final topics = await CsvService.getAvailableTopics();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _availableTopics = topics;
      _intervalMinutes = prefs.getInt('notificationIntervalMinutes') ?? 60;
      _startTime = TimeOfDay(
        hour: prefs.getInt('notificationStartHour') ?? 9,
        minute: prefs.getInt('notificationStartMinute') ?? 0,
      );
      _endTime = TimeOfDay(
        hour: prefs.getInt('notificationEndHour') ?? 19,
        minute: prefs.getInt('notificationEndMinute') ?? 0,
      );
      _selectedPopularity =
          prefs.getStringList('selectedPopularity') ?? List.from(_allPopularityLevels);
      _selectedTopics = prefs.getStringList('selectedTopics') ?? [];
      _isLoading = false;
    });
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationIntervalMinutes', _intervalMinutes);
    await prefs.setInt('notificationStartHour', _startTime.hour);
    await prefs.setInt('notificationStartMinute', _startTime.minute);
    await prefs.setInt('notificationEndHour', _endTime.hour);
    await prefs.setInt('notificationEndMinute', _endTime.minute);
    await prefs.setStringList('selectedPopularity', _selectedPopularity);
    await prefs.setStringList('selectedTopics', _selectedTopics);

    if (_intervalMinutes > 0) {
      await NotificationService().requestPermissions();

      final pool = <Vocabulary>[];
      if (_selectedTopics.isNotEmpty) {
        pool.addAll(await CsvService.loadSpecificTopicsVocabulary(
            _selectedTopics, levelFilter: _selectedPopularity, excludeKnown: true));
      } else {
        pool.addAll(await CsvService.loadSpecificPopularityVocabulary(
            _selectedPopularity, excludeKnown: true));
      }

      await NotificationService().scheduleVocabularyNotifications(
        pool: pool,
        intervalMinutes: _intervalMinutes,
        startTime: _startTime,
        endTime: _endTime,
      );

      if (Platform.isAndroid) {
        final ok = await NotificationService().isIgnoringBatteryOptimizations();
        if (!ok && prefs.getBool('batteryOptPrompted') != true) {
          await prefs.setBool('batteryOptPrompted', true);
          if (mounted) await _showBatteryOptPrompt();
        }
        await _refreshBatteryStatus();
      }
    } else {
      await NotificationService().cancelAllNotifications();
    }

    UserDataService().uploadSettings();

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _dirty = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification preferences saved')),
    );
  }

  Future<void> _showBatteryOptPrompt() async {
    final accept = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text('Keep notifications running'),
        content: const Text(
          'Android may pause ELED notifications after a day to save battery. '
          'Allow ELED to run unrestricted so vocabulary reminders keep firing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
    if (accept == true) {
      await NotificationService().requestIgnoreBatteryOptimizations();
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
            colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
              primary: context.bBorder,
              onPrimary: context.bBg,
              onSurface: context.bBorder,
              surface: context.bBg,
            ),
            dialogTheme: DialogThemeData(backgroundColor: context.bBg),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
      _markDirty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: (_dirty && !_isSaving) ? _save : null,
            child: Text(
              'Save',
              style: TextStyle(
                color: (_dirty && !_isSaving) ? BrutalistTheme.primary : context.bMuted,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading || _isSaving
          ? Center(child: CircularProgressIndicator(color: context.bBorder, strokeWidth: 5))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    'Frequency',
                    subtitle: 'How often to send a new vocabulary word',
                  ),
                  _buildIntervalSelector(),
                  if (Platform.isAndroid && !_batteryUnrestricted) ...[
                    const SizedBox(height: 16),
                    _buildBatteryOptCard(),
                  ],
                  const SizedBox(height: 32),

                  const SectionHeader(
                    'Active hours',
                    subtitle: 'Reminders only fire inside this window',
                  ),
                  Row(
                    children: [
                      Expanded(child: _timeCard('From', _startTime, BrutalistTheme.accent, () => _pickTime(true))),
                      const SizedBox(width: 16),
                      Expanded(child: _timeCard('Until', _endTime, BrutalistTheme.primary, () => _pickTime(false))),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const SectionHeader(
                    'Difficulty levels',
                    subtitle: 'Choose which CEFR levels to include',
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allPopularityLevels.map(_buildPopularityChip).toList(),
                  ),
                  const SizedBox(height: 32),

                  const SectionHeader(
                    'Topics',
                    subtitle: 'Optional — leave empty to use all topics',
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableTopics.map(_buildTopicChip).toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _timeCard(String label, TimeOfDay time, Color bg, VoidCallback onTap) {
    return BrutalistCard(
      backgroundColor: bg,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: BrutalistTheme.black)),
            const SizedBox(height: 4),
            Text(time.format(context),
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: BrutalistTheme.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularityChip(String level) {
    final isSelected = _selectedPopularity.contains(level);
    return FilterChip(
      label: Text(level,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? BrutalistTheme.white : context.bBorder)),
      selected: isSelected,
      onSelected: (sel) {
        setState(() {
          if (sel) {
            _selectedPopularity.add(level);
          } else {
            _selectedPopularity.remove(level);
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
      label: Text(topic.replaceAll('_', ' '),
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? BrutalistTheme.white : context.bBorder)),
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

  Widget _buildIntervalSelector() {
    const options = {
      0: 'Off',
      1: '1 min',
      10: '10 min',
      15: '15 min',
      20: '20 min',
      25: '25 min',
      30: '30 min',
      60: '60 min',
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.entries.map((entry) {
        final isSelected = _intervalMinutes == entry.key;
        return GestureDetector(
          onTap: () {
            setState(() => _intervalMinutes = entry.key);
            _markDirty();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected ? BrutalistTheme.primary : context.bBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? BrutalistTheme.primary : context.bSubtle,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: BrutalistTheme.primary.withValues(alpha: 0.22),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              entry.value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? BrutalistTheme.white : context.bBorder,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBatteryOptCard() {
    return BrutalistCard(
      backgroundColor: BrutalistTheme.primaryLight,
      onTap: () async {
        await NotificationService().requestIgnoreBatteryOptimizations();
        await Future.delayed(const Duration(milliseconds: 500));
        await _refreshBatteryStatus();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.battery_alert_rounded, color: BrutalistTheme.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Allow background activity',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700, color: BrutalistTheme.primary)),
                  Text('Tap to keep notifications firing past 1 day',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BrutalistTheme.primary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: BrutalistTheme.primary),
          ],
        ),
      ),
    );
  }
}
