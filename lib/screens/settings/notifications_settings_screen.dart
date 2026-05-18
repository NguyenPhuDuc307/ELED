import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/gen/app_localizations.dart';
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
  int _maxCount = 5;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 19, minute: 0);

  bool _isLoading = true;
  bool _isSaving = false;
  bool _dirty = false;
  bool _batteryUnrestricted = true;

  static const _maxCountCeiling = 5;

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
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _intervalMinutes = prefs.getInt('notificationIntervalMinutes') ?? 60;
      _maxCount =
          (prefs.getInt('notificationMaxCount') ?? 5).clamp(1, _maxCountCeiling);
      _startTime = TimeOfDay(
        hour: prefs.getInt('notificationStartHour') ?? 9,
        minute: prefs.getInt('notificationStartMinute') ?? 0,
      );
      _endTime = TimeOfDay(
        hour: prefs.getInt('notificationEndHour') ?? 19,
        minute: prefs.getInt('notificationEndMinute') ?? 0,
      );
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
    await prefs.setInt('notificationMaxCount', _maxCount);
    await prefs.setInt('notificationStartHour', _startTime.hour);
    await prefs.setInt('notificationStartMinute', _startTime.minute);
    await prefs.setInt('notificationEndHour', _endTime.hour);
    await prefs.setInt('notificationEndMinute', _endTime.minute);

    if (_intervalMinutes > 0) {
      await NotificationService().requestPermissions();

      // Level + topic filters live in Vocabulary preferences now — read them
      // through here so changing one screen takes effect across the app.
      final popularity = prefs.getStringList('selectedPopularity') ??
          ['A1', 'A2', 'B1', 'B2', 'C1'];
      final topics = prefs.getStringList('selectedTopics') ?? const <String>[];
      final pool = await NotificationService.loadPool(
        popularity: popularity,
        topics: topics,
      );

      await NotificationService().scheduleVocabularyNotifications(
        pool: pool,
        intervalMinutes: _intervalMinutes,
        startTime: _startTime,
        endTime: _endTime,
        maxCount: _maxCount,
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
    final t = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.notificationsSaved),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showBatteryOptPrompt() async {
    final t = AppLocalizations.of(context);
    final accept = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: Text(t.notificationsBatteryTitle),
        content: Text(t.notificationsBatteryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            child: Text(t.commonNotNow),
          ),
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            child: Text(t.commonAllow),
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
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.notificationsTitle),
        actions: [
          TextButton(
            onPressed: (_dirty && !_isSaving) ? _save : null,
            child: Text(
              t.commonSave,
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
                  SectionHeader(
                    t.notificationsFrequency,
                    subtitle: t.notificationsFrequencySubtitle,
                  ),
                  _buildIntervalSelector(t),
                  const SizedBox(height: 24),
                  SectionHeader(
                    t.notificationsMaxCount,
                    subtitle: t.notificationsMaxCountSubtitle,
                  ),
                  _buildMaxCountSelector(t),
                  if (Platform.isAndroid && !_batteryUnrestricted) ...[
                    const SizedBox(height: 16),
                    _buildBatteryOptCard(t),
                  ],
                  const SizedBox(height: 32),

                  SectionHeader(
                    t.notificationsActiveHours,
                    subtitle: t.notificationsActiveHoursSubtitle,
                  ),
                  Row(
                    children: [
                      Expanded(child: _timeCard(t.notificationsFrom, _startTime, BrutalistTheme.accent, () => _pickTime(true))),
                      const SizedBox(width: 16),
                      Expanded(child: _timeCard(t.notificationsUntil, _endTime, BrutalistTheme.primary, () => _pickTime(false))),
                    ],
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

  Widget _buildIntervalSelector(AppLocalizations t) {
    final options = <int, String>{
      0: t.notificationsOff,
      1: t.notificationsIntervalMinutes(1),
      10: t.notificationsIntervalMinutes(10),
      15: t.notificationsIntervalMinutes(15),
      20: t.notificationsIntervalMinutes(20),
      25: t.notificationsIntervalMinutes(25),
      30: t.notificationsIntervalMinutes(30),
      60: t.notificationsIntervalMinutes(60),
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

  Widget _buildMaxCountSelector(AppLocalizations t) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_maxCountCeiling, (i) {
        final value = i + 1;
        final isSelected = _maxCount == value;
        return GestureDetector(
          onTap: () {
            setState(() => _maxCount = value);
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
              t.notificationsMaxCountValue(value),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? BrutalistTheme.white : context.bBorder,
                  ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBatteryOptCard(AppLocalizations t) {
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
                  Text(t.notificationsBatteryCardTitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700, color: BrutalistTheme.primary)),
                  Text(t.notificationsBatteryCardSubtitle,
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
