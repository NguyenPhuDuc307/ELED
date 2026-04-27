import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/csv_service.dart';
import '../services/update_service.dart';
import '../services/user_data_service.dart';
import '../theme/brutalist_theme.dart';
import '../main.dart';
import '../models/vocabulary.dart';
import '../widgets/brutalist_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _intervalMinutes = 60;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 19, minute: 0);
  
  List<String> _availableTopics = [];
  List<String> _selectedPopularity = [];
  List<String> _selectedTopics = [];
  bool _isSaving = false;
  bool _isLoading = true;
  String _themeModeStr = 'system';
  User? _user;

  // Update check state
  String _currentVersion = '';
  UpdateInfo? _updateInfo;
  bool _checkingUpdate = false;
  bool _updateChecked = false;

  final List<String> _allPopularityLevels = ['A1', 'A2', 'B1', 'B2', 'C1'];

  @override
  void initState() {
    super.initState();
    _user = AuthService().currentUser;
    AuthService().userStream.listen((u) {
      if (mounted) setState(() => _user = u);
    });
    UserDataService().settingsStream.listen((settings) {
      if (!mounted) return;
      final theme = settings['themeMode'] as String? ?? _themeModeStr;
      final newMode = theme == 'dark' ? ThemeMode.dark : (theme == 'light' ? ThemeMode.light : ThemeMode.system);
      EledApp.themeNotifier.value = newMode;
      _loadSettingsAndData();
    });
    _loadSettingsAndData();
  }

  Future<void> _loadSettingsAndData() async {
    final topics = await CsvService.getAvailableTopics();
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _availableTopics = topics;
      _intervalMinutes = prefs.getInt('notificationIntervalMinutes') ?? 60;
      
      final startH = prefs.getInt('notificationStartHour') ?? 9;
      final startM = prefs.getInt('notificationStartMinute') ?? 0;
      _startTime = TimeOfDay(hour: startH, minute: startM);

      final endH = prefs.getInt('notificationEndHour') ?? 19;
      final endM = prefs.getInt('notificationEndMinute') ?? 0;
      _endTime = TimeOfDay(hour: endH, minute: endM);

      _selectedPopularity = prefs.getStringList('selectedPopularity') ?? List.from(_allPopularityLevels);
      _selectedTopics = prefs.getStringList('selectedTopics') ?? [];
      _themeModeStr = prefs.getString('themeMode') ?? 'system';
      
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationIntervalMinutes', _intervalMinutes);
    await prefs.setInt('notificationStartHour', _startTime.hour);
    await prefs.setInt('notificationStartMinute', _startTime.minute);
    await prefs.setInt('notificationEndHour', _endTime.hour);
    await prefs.setInt('notificationEndMinute', _endTime.minute);
    await prefs.setStringList('selectedPopularity', _selectedPopularity);
    await prefs.setStringList('selectedTopics', _selectedTopics);
    await prefs.setString('themeMode', _themeModeStr);

    final newTheme = _themeModeStr == 'dark' ? ThemeMode.dark : (_themeModeStr == 'light' ? ThemeMode.light : ThemeMode.system);
    EledApp.themeNotifier.value = newTheme;

    if (_intervalMinutes > 0) {
      await NotificationService().requestPermissions();
      
      List<Vocabulary> pool = [];
      if (_selectedTopics.isNotEmpty) {
        pool.addAll(await CsvService.loadSpecificTopicsVocabulary(_selectedTopics, levelFilter: _selectedPopularity, excludeKnown: true));
      } else {
        pool.addAll(await CsvService.loadSpecificPopularityVocabulary(_selectedPopularity, excludeKnown: true));
      }

      await NotificationService().scheduleVocabularyNotifications(
        pool: pool,
        intervalMinutes: _intervalMinutes,
        startTime: _startTime,
        endTime: _endTime,
      );
    } else {
      await NotificationService().cancelAllNotifications();
    }

    UserDataService().uploadSettings();

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved!')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _checkUpdate() async {
    if (_checkingUpdate) return;
    setState(() {
      _checkingUpdate = true;
      _updateChecked = false;
    });
    final version = await UpdateService.currentVersion();
    final info = await UpdateService.checkForUpdate();
    if (!mounted) return;
    setState(() {
      _currentVersion = version;
      _updateInfo = info;
      _checkingUpdate = false;
      _updateChecked = true;
    });
  }

  Future<void> _pickTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveSettings,
            child: Text(
              'Save',
              style: TextStyle(
                color: BrutalistTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading || _isSaving
          ? Center(
              child: CircularProgressIndicator(
                color: context.bBorder,
                strokeWidth: 6,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAccountSection(),
                  const SizedBox(height: 32),
                  Divider(color: context.bBorder, thickness: 4),
                  const SizedBox(height: 32),

                  Text(
                    'NOTIFICATION INTERVAL',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildIntervalSelector(),
                  const SizedBox(height: 32),
                  Divider(color: context.bBorder, thickness: 4),
                  const SizedBox(height: 32),

                  Text(
                    'APP THEME',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildThemeSelector(),
                  const SizedBox(height: 32),
                  Divider(color: context.bBorder, thickness: 4),
                  const SizedBox(height: 32),
                  
                  Text(
                    'ACTIVE TIME WINDOW',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: BrutalistCard(
                          backgroundColor: BrutalistTheme.accent,
                          onTap: () => _pickTime(true),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text('FROM', style: TextStyle(fontWeight: FontWeight.bold, color: BrutalistTheme.black)),
                                Text(_startTime.format(context), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: BrutalistTheme.black)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: BrutalistCard(
                          backgroundColor: BrutalistTheme.primary,
                          onTap: () => _pickTime(false),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text('UNTIL', style: TextStyle(fontWeight: FontWeight.bold, color: BrutalistTheme.black)),
                                Text(_endTime.format(context), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: BrutalistTheme.black)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Divider(color: context.bBorder, thickness: 4),
                  const SizedBox(height: 32),

                  Text(
                    'POPULARITY LEVELS',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _allPopularityLevels.map((level) {
                      final isSelected = _selectedPopularity.contains(level);
                      return FilterChip(
                        label: Text(level, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? BrutalistTheme.white : context.bBorder)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedPopularity.add(level);
                            } else {
                              _selectedPopularity.remove(level);
                            }
                          });
                        },
                        selectedColor: BrutalistTheme.primary,
                        backgroundColor: context.bBg,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? BrutalistTheme.primary : context.bSubtle, width: 1.5),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                  Text(
                    'TOPICS',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _availableTopics.map((topic) {
                      final isSelected = _selectedTopics.contains(topic);
                      return FilterChip(
                        label: Text(
                          topic.replaceAll('_', ' '),
                          style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? BrutalistTheme.white : context.bBorder),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTopics.add(topic);
                            } else {
                              _selectedTopics.remove(topic);
                            }
                          });
                        },
                        selectedColor: BrutalistTheme.primary,
                        backgroundColor: context.bBg,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? BrutalistTheme.primary : context.bSubtle, width: 1.5),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                  Divider(color: context.bBorder, thickness: 4),
                  const SizedBox(height: 32),

                  Text(
                    'APP VERSION',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildUpdateSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildUpdateSection() {
    return BrutalistCard(
      backgroundColor: context.bBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BrutalistTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.system_update_rounded, color: BrutalistTheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current version',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.bMuted),
                      ),
                      Text(
                        'v$_currentVersion',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                // Check button
                _checkingUpdate
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: BrutalistTheme.primary),
                      )
                    : TextButton(
                        onPressed: _checkUpdate,
                        child: Text(
                          'Check',
                          style: TextStyle(color: BrutalistTheme.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
              ],
            ),
            if (_updateChecked) ...[
              const SizedBox(height: 12),
              if (_updateInfo != null) ...[
                // New version available
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BrutalistTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.new_releases_rounded, color: BrutalistTheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'v${_updateInfo!.version} available!',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: BrutalistTheme.primary,
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final url = Uri.parse(
                            _updateInfo!.apkUrl.isNotEmpty
                                ? _updateInfo!.apkUrl
                                : _updateInfo!.releaseUrl,
                          );
                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not open link.')),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Download',
                          style: TextStyle(color: BrutalistTheme.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Up to date
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: BrutalistTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'You\'re up to date',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: BrutalistTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    if (_user == null) {
      return BrutalistCard(
        backgroundColor: context.bBg,
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);
          setState(() => _isSaving = true);
          try {
            final user = await AuthService().signInWithGoogle();
            if (user != null) {
              messenger.showSnackBar(const SnackBar(content: Text('Signed in!')));
            }
          } catch (e) {
            messenger.showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
          } finally {
            if (mounted) setState(() => _isSaving = false);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: BrutalistTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_circle_outlined, color: BrutalistTheme.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sign in with Google',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    Text('Sync known words, collections & history',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.bMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.bMuted),
            ],
          ),
        ),
      );
    }

    return BrutalistCard(
      backgroundColor: BrutalistTheme.primaryLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: _user!.photoURL != null ? NetworkImage(_user!.photoURL!) : null,
              backgroundColor: BrutalistTheme.primary,
              child: _user!.photoURL == null
                  ? Text(_user!.displayName?[0] ?? '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_user!.displayName ?? 'Google User',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600, color: const Color(0xFF2A4A28))),
                  Text(_user!.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF2A4A28).withValues(alpha: 0.7))),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFF2A4A28)),
                  tooltip: 'Sign out',
                  onPressed: () async {
                    await AuthService().signOut();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Signed out.')),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalSelector() {
    final options = {
      0: 'OFF',
      1: '1 MIN',
      10: '10 MIN',
      15: '15 MIN',
      20: '20 MIN',
      25: '25 MIN',
      30: '30 MIN',
      60: '60 MIN',
    };

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: options.entries.map((entry) {
        final isSelected = _intervalMinutes == entry.key;
        return GestureDetector(
          onTap: () => setState(() => _intervalMinutes = entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? BrutalistTheme.primary : context.bBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? BrutalistTheme.primary : context.bSubtle,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: BrutalistTheme.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
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

  Widget _buildThemeSelector() {
    final options = {
      'system': 'SYSTEM DEFAULT',
      'light': 'LIGHT MODE',
      'dark': 'DARK MODE',
    };

    return Column(
      children: options.entries.map((entry) {
        final isSelected = _themeModeStr == entry.key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: BrutalistCard(
            backgroundColor: isSelected ? BrutalistTheme.accent : context.bBg,
            onTap: () {
              setState(() {
                _themeModeStr = entry.key;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                   Icon(
                    isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? BrutalistTheme.black : context.bBorder,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                          color: isSelected ? BrutalistTheme.black : context.bBorder,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
