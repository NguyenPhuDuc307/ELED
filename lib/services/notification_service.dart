import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary.dart';
import '../services/csv_service.dart';
import '../screens/learning_screen.dart';
import '../main.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int androidAlarmId = 1000;

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static Future<void> _onNotificationTapped(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      if (globalNavigatorKey.currentState == null) {
        pendingNotificationPayload = payload;
        return;
      }
      
      final context = globalNavigatorKey.currentState?.context;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('NATIVE INTENT: $payload')));
      }

      final allVocab = await CsvService.loadAllVocabulary(excludeKnown: false);
      final matchPayload = payload.trim().toLowerCase();
      final matchList = allVocab.where((v) => v.word.trim().toLowerCase() == matchPayload);
      if (matchList.isNotEmpty) {
        globalNavigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => LearningScreen(
              day: 0,
              vocabularies: [matchList.first],
            ),
          ),
        );
      } else {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('404: $payload NOT IN DB! (DB=${allVocab.length})')));
        }
      }
    }
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static DateTime _calculateNextSlot(DateTime now, int startH, int startM, int endH, int endM, int intervalMins) {
    if (intervalMins <= 0) return now.add(const Duration(minutes: 60)); 
    
    DateTime candidate = DateTime(now.year, now.month, now.day, startH, startM);
    // Pad by 1 minute to prevent Android Alarm early-firing infinite recursion loops
    final safeNow = now.add(const Duration(minutes: 1));
    
    while (candidate.isBefore(safeNow)) {
      candidate = candidate.add(Duration(minutes: intervalMins));
    }
    
    DateTime todayEnd = DateTime(now.year, now.month, now.day, endH, endM);
    if (candidate.isAfter(todayEnd)) {
      candidate = DateTime(now.year, now.month, now.day + 1, startH, startM);
    }
    
    return candidate;
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    if (Platform.isAndroid) {
      await AndroidAlarmManager.cancel(androidAlarmId);
    }
  }

  Future<void> scheduleVocabularyNotifications({
    required List<Vocabulary> pool,
    required int intervalMinutes,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    await cancelAllNotifications();

    if (pool.isEmpty || intervalMinutes <= 0) return;

    if (Platform.isAndroid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notificationIntervalMinutes', intervalMinutes);
      await prefs.setInt('notificationStartHour', startTime.hour);
      await prefs.setInt('notificationStartMinute', startTime.minute);
      await prefs.setInt('notificationEndHour', endTime.hour);
      await prefs.setInt('notificationEndMinute', endTime.minute);

      final nextSlot = _calculateNextSlot(DateTime.now(), startTime.hour, startTime.minute, endTime.hour, endTime.minute, intervalMinutes);

      await AndroidAlarmManager.oneShotAt(
        nextSlot,
        androidAlarmId,
        androidAlarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
    } else {
      // iOS: Standard pre-scheduling algorithm (does not support home widgets synced real-time dynamically out of the box easily)
      final now = tz.TZDateTime.now(tz.local);
      int scheduleCount = min(50, pool.length);
      List<Vocabulary> shuffledPool = List.from(pool)..shuffle();

      tz.TZDateTime nextTime = now;

      for (int i = 0; i < scheduleCount; i++) {
        final vocab = shuffledPool[i];
        nextTime = nextTime.add(Duration(minutes: intervalMinutes));
        
        int curMins = nextTime.hour * 60 + nextTime.minute;
        int startMins = startTime.hour * 60 + startTime.minute;
        int endMins = endTime.hour * 60 + endTime.minute;

        if (curMins >= endMins || curMins < startMins) {
          if (curMins >= endMins) {
            nextTime = tz.TZDateTime(tz.local, nextTime.year, nextTime.month, nextTime.day + 1, startTime.hour, startTime.minute);
          } else {
            nextTime = tz.TZDateTime(tz.local, nextTime.year, nextTime.month, nextTime.day, startTime.hour, startTime.minute);
          }
        }

        String htmlBody = '<b>Nghĩa:</b> ${vocab.translation}<br>';
        if (vocab.ipa.isNotEmpty) {
          htmlBody += '<b>Phiên âm:</b> <i>${vocab.ipa}</i><br>';
        }
        htmlBody += '<b>Từ loại:</b> ${vocab.partOfSpeech.toUpperCase()} &bull; <b>Level:</b> ${vocab.levels.toUpperCase()}';

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: i,
          title: vocab.word.toUpperCase(),
          body: '${vocab.translation} - ${vocab.partOfSpeech}',
          scheduledDate: nextTime,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'eled_vocab_channel',
              'Vocabulary Reminders',
              channelDescription: 'Periodic vocabulary notifications',
              importance: Importance.max,
              priority: Priority.high,
              color: const Color(0xFFE2F040),
              styleInformation: BigTextStyleInformation(
                htmlBody, 
                htmlFormatBigText: true,
                contentTitle: '<b>${vocab.word.toUpperCase()}</b>',
                htmlFormatContentTitle: true,
              ),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }

}

@pragma('vm:entry-point')
Future<void> androidAlarmCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Force read from disk to avoid stale warm isolate cache
    
    final startH = prefs.getInt('notificationStartHour') ?? 9;
    final startM = prefs.getInt('notificationStartMinute') ?? 0;
    final endH = prefs.getInt('notificationEndHour') ?? 19;
    final endM = prefs.getInt('notificationEndMinute') ?? 0;
    
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    final startMin = startH * 60 + startM;
    final endMin = endH * 60 + endM;
    
    if (nowMin < startMin || nowMin > endMin) {
      return; // Outside active window
    }

    final popularity = prefs.getStringList('selectedPopularity') ?? [];
    final topics = prefs.getStringList('selectedTopics') ?? [];
    
    List<Vocabulary> pool = [];
    pool.addAll(await CsvService.loadSpecificPopularityVocabulary(popularity, excludeKnown: true));
    pool.addAll(await CsvService.loadSpecificTopicsVocabulary(topics, excludeKnown: true));
    
    if (pool.isEmpty) return;
    
    final random = Random();
    final vocab = pool[random.nextInt(pool.length)];
    
    // Sync strictly with Android Widget, isolated try-catch to prevent crash
    try {
      await HomeWidget.saveWidgetData<String>('word', vocab.word);
      await HomeWidget.saveWidgetData<String>('translation', vocab.translation);
      await HomeWidget.saveWidgetData<String>('ipa', vocab.ipa);
      await HomeWidget.updateWidget(name: 'VocabularyWidgetProvider');
    } catch (e) {
      debugPrint("HomeWidget background update failed: $e");
    }
    
    // Trigger the local notification manually
    final flnp = FlutterLocalNotificationsPlugin();

    String htmlBody = '<b>Nghĩa:</b> ${vocab.translation}<br>';
    if (vocab.ipa.isNotEmpty) {
      htmlBody += '<b>Phiên âm:</b> <i>${vocab.ipa}</i><br>';
    }
    htmlBody += '<b>Từ loại:</b> ${vocab.partOfSpeech.toUpperCase()} &bull; <b>Level:</b> ${vocab.levels.toUpperCase()}';

    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'eled_vocab_channel',
      'Vocabulary Reminders',
      channelDescription: 'Periodic vocabulary notifications',
      icon: '@mipmap/launcher_icon',
      importance: Importance.max,
      priority: Priority.high,
      color: const Color(0xFFE2F040),
      styleInformation: BigTextStyleInformation(
        htmlBody, 
        htmlFormatBigText: true,
        contentTitle: '<b>${vocab.word.toUpperCase()}</b>',
        htmlFormatContentTitle: true,
      ),
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flnp.show(
      id: 0, 
      title: vocab.word.toUpperCase(),
      body: '${vocab.translation} - ${vocab.partOfSpeech}',
      notificationDetails: platformChannelSpecifics,
      payload: vocab.word,
    );

    // Save to history tracking
    try {
      final history = prefs.getStringList('notificationHistory') ?? [];
      history.remove(vocab.word); // Always remove old instance
      history.insert(0, vocab.word); // Add to top
      if (history.length > 500) history.removeLast(); // Keep max 500 items
      await prefs.setStringList('notificationHistory', history);
    } catch (e) {
      debugPrint("Failed to save history: $e");
    }

  } catch (e) {
    debugPrint("AlarmManager callback error: $e");
  } finally {
    // RECURSIVE SCHEDULING TO BYPASS ANDROID 15-MINUTE PERIODIC LIMIT
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final interval = prefs.getInt('notificationIntervalMinutes') ?? 60;
    final startH = prefs.getInt('notificationStartHour') ?? 9;
    final startM = prefs.getInt('notificationStartMinute') ?? 0;
    final endH = prefs.getInt('notificationEndHour') ?? 19;
    final endM = prefs.getInt('notificationEndMinute') ?? 0;
    
    final nextSlot = NotificationService._calculateNextSlot(DateTime.now(), startH, startM, endH, endM, interval);

    await AndroidAlarmManager.oneShotAt(
      nextSlot,
      1000, // androidAlarmId
      androidAlarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }
}
