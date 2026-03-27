import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/menu_screen.dart';
import 'dart:io';
import 'theme/brutalist_theme.dart';
import 'services/notification_service.dart';
import 'services/csv_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'models/vocabulary.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();
String? pendingNotificationPayload;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
  }
  
  final prefs = await SharedPreferences.getInstance();
  final themeStr = prefs.getString('themeMode') ?? 'system';
  final initialTheme = themeStr == 'dark' ? ThemeMode.dark : (themeStr == 'light' ? ThemeMode.light : ThemeMode.system);
  EledApp.themeNotifier.value = initialTheme;
  
  await NotificationService().init();
  
  final launchDetails = await NotificationService().flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (launchDetails?.didNotificationLaunchApp ?? false) {
    pendingNotificationPayload = launchDetails!.notificationResponse?.payload;
  }
  
  _restockNotifications();

  runApp(const EledApp());
}

Future<void> _restockNotifications() async {
  if (Platform.isAndroid) return; // Android relies on self-rescheduling background isolates. Restocking on boot resets the timer and fires a rogue immediate intent!
  
  try {
    final prefs = await SharedPreferences.getInstance();
    final int intervalMinutes = prefs.getInt('notificationIntervalMinutes') ?? 60;
    
    if (intervalMinutes > 0) {
      final startH = prefs.getInt('notificationStartHour') ?? 9;
      final startM = prefs.getInt('notificationStartMinute') ?? 0;
      final endH = prefs.getInt('notificationEndHour') ?? 19;
      final endM = prefs.getInt('notificationEndMinute') ?? 0;

      final selectedPopularity = prefs.getStringList('selectedPopularity') ?? ['A1', 'A2', 'B1', 'B2', 'C1'];
      final selectedTopics = prefs.getStringList('selectedTopics') ?? [];

      List<Vocabulary> pool = [];
      pool.addAll(await CsvService.loadSpecificPopularityVocabulary(selectedPopularity, excludeKnown: true));
      pool.addAll(await CsvService.loadSpecificTopicsVocabulary(selectedTopics, excludeKnown: true));
      
      if (pool.isNotEmpty) {
        await NotificationService().scheduleVocabularyNotifications(
          pool: pool,
          intervalMinutes: intervalMinutes,
          startTime: TimeOfDay(hour: startH, minute: startM),
          endTime: TimeOfDay(hour: endH, minute: endM),
        );
      }
    }
  } catch (e) {
    debugPrint('Failed to restock notifications: $e');
  }
}

class EledApp extends StatelessWidget {
  const EledApp({super.key});

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
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
