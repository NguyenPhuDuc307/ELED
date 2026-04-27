import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/menu_screen.dart';
import 'screens/sync_screen.dart';
import 'services/vocabulary_sync_service.dart';
import 'theme/brutalist_theme.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/update_service.dart';
import 'services/user_data_service.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
String? pendingNotificationPayload;
String? pendingMarkKnownWord;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await HomeWidget.setAppGroupId('group.com.nguyenphuduc.eled');

  final (prefs, _) = await (
    SharedPreferences.getInstance(),
    Future.wait([
      NotificationService().init(),
      AuthService().initialize(),
      UserDataService().initialize(),
    ]),
  ).wait;

  final themeStr = prefs.getString('themeMode') ?? 'system';
  EledApp.themeNotifier.value = themeStr == 'dark'
      ? ThemeMode.dark
      : (themeStr == 'light' ? ThemeMode.light : ThemeMode.system);

  final launchDetails = await NotificationService()
      .flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails();
  if (launchDetails?.didNotificationLaunchApp ?? false) {
    pendingNotificationPayload = launchDetails!.notificationResponse?.payload;
  }

  await NotificationService.processScheduleLog();
  _ensureNotificationVersion();

  if (Platform.isAndroid) {
    const MethodChannel('com.nguyenphuduc.eled/knownwords')
        .setMethodCallHandler((call) async {
      if (call.method == 'markKnown') {
        final word = call.arguments as String?;
        if (word != null && word.isNotEmpty) {
          await UserDataService().addKnownWord(word);
        }
      }
    });
  }

  final needsSync = !await VocabularySyncService.hasLocalData() ||
      await VocabularySyncService.isOutdated();
  runApp(EledApp(needsSync: needsSync));

  _autoCheckForUpdate();
}

Future<void> _autoCheckForUpdate() async {
  try {
    if (!await UpdateService.isAutoCheckEnabled()) return;
    final info = await UpdateService.checkForUpdate();
    if (info != null) await NotificationService.showUpdateNotification(info);
  } catch (_) {}
}

// Bump this string whenever notification format changes (actions, channels, etc.)
const _kNotificationFormatVersion = 'v4-native';

Future<void> _ensureNotificationVersion() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('notification_format_version') == _kNotificationFormatVersion) {
      _restockNotifications();
      return;
    }
    // Format changed → cancel all and reschedule with new format
    await NotificationService().cancelAllNotifications();
    await prefs.setString('notification_format_version', _kNotificationFormatVersion);
    _restockNotifications();
  } catch (e) {
    debugPrint('Failed to ensure notification version: $e');
  }
}

Future<void> _restockNotifications() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final intervalMinutes = prefs.getInt('notificationIntervalMinutes') ?? 0;
    if (intervalMinutes <= 0) return;

    // On Android, notifications are scheduled natively via AlarmManager so
    // flutterLocalNotificationsPlugin.pendingNotificationRequests() always returns 0.
    // Count future entries in the schedule log instead.
    final log = prefs.getStringList('notificationScheduleLog') ?? [];
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final futureCount = log.where((e) {
      final ms = int.tryParse(e.split('|')[0]) ?? 0;
      return ms > nowMs;
    }).length;
    if (futureCount >= 10) return;

    final startH = prefs.getInt('notificationStartHour') ?? 9;
    final startM = prefs.getInt('notificationStartMinute') ?? 0;
    final endH   = prefs.getInt('notificationEndHour') ?? 19;
    final endM   = prefs.getInt('notificationEndMinute') ?? 0;

    final popularity = prefs.getStringList('selectedPopularity') ?? ['A1', 'A2', 'B1', 'B2', 'C1'];
    final topics     = prefs.getStringList('selectedTopics') ?? [];
    final pool       = await NotificationService.loadPool(popularity: popularity, topics: topics);

    if (pool.isNotEmpty) {
      await NotificationService().scheduleVocabularyNotifications(
        pool: pool,
        intervalMinutes: intervalMinutes,
        startTime: TimeOfDay(hour: startH, minute: startM),
        endTime: TimeOfDay(hour: endH, minute: endM),
      );
    }
  } catch (e) {
    debugPrint('Failed to restock notifications: $e');
  }
}

class EledApp extends StatefulWidget {
  const EledApp({super.key, this.needsSync = false});

  final bool needsSync;

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.system);

  @override
  State<EledApp> createState() => _EledAppState();
}

class _EledAppState extends State<EledApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      NotificationService.processScheduleLog();
      _restockNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: EledApp.themeNotifier,
      builder: (context, ThemeMode currentMode, child) {
        return MaterialApp(
          navigatorKey: globalNavigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          title: 'ELED - English Learning',
          theme: BrutalistTheme.lightTheme,
          darkTheme: BrutalistTheme.darkTheme,
          themeMode: currentMode,
          home: widget.needsSync ? const SyncScreen() : const MenuScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
