import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/menu_screen.dart';
import 'theme/brutalist_theme.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();
String? pendingNotificationPayload;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final (prefs, _) = await (
    SharedPreferences.getInstance(),
    Future.wait([
      NotificationService().init(),
      AuthService().initialize(),
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
  _restockNotifications();
  runApp(const EledApp());
}

Future<void> _restockNotifications() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final intervalMinutes = prefs.getInt('notificationIntervalMinutes') ?? 0;
    if (intervalMinutes <= 0) return;

    // Only restock if running low (< 10 pending) to avoid cancelling upcoming noti
    final pending = await NotificationService()
        .flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    if (pending.length >= 10) return;

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
  const EledApp({super.key});

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
          title: 'ELED - English Learning',
          theme: BrutalistTheme.lightTheme,
          darkTheme: BrutalistTheme.darkTheme,
          themeMode: currentMode,
          home: const MenuScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
