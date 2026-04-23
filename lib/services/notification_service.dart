import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/vocabulary.dart';
import '../services/csv_service.dart';
import '../screens/learning_screen.dart';
import '../main.dart';

const kAndroidChannel = AndroidNotificationDetails(
  'eled_vocab_channel',
  'Vocabulary Reminders',
  channelDescription: 'Periodic vocabulary notifications',
  importance: Importance.max,
  priority: Priority.high,
);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    HomeWidget.widgetClicked.listen(_onWidgetTapped);
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_onWidgetTapped);
  }

  static Future<void> _onWidgetTapped(Uri? uri) async {
    if (uri != null && uri.scheme == 'eled') {
      final payload = uri.queryParameters['payload'];
      if (payload != null && payload.isNotEmpty) {
        _onNotificationTapped(NotificationResponse(
          notificationResponseType: NotificationResponseType.selectedNotification,
          payload: payload,
        ));
      }
    }
  }

  static Future<void> _onNotificationTapped(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    if (globalNavigatorKey.currentState == null) {
      pendingNotificationPayload = payload;
      return;
    }

    final allVocab = await CsvService.loadAllVocabulary(excludeKnown: false);
    final parts      = payload.split('|');
    final matchWord  = parts[0].trim().toLowerCase();
    final matchTopic = parts.length > 1 ? parts[1].trim().toLowerCase() : '';

    final matches = allVocab.where((v) => v.word.trim().toLowerCase() == matchWord);
    if (matches.isEmpty) return;

    final exact = matches.where((v) => v.topic.trim().toLowerCase() == matchTopic);
    final vocab = exact.isNotEmpty ? exact.first : matches.first;

    // Save tapped notification to history immediately
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('notificationHistory') ?? [];
      final entry = '${vocab.word}|${vocab.topic}';
      history.removeWhere((e) => e == vocab.word || e.startsWith('${vocab.word}|'));
      history.insert(0, entry);
      if (history.length > 500) history.length = 500;
      await prefs.setStringList('notificationHistory', history);
    } catch (_) {}

    globalNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => LearningScreen(day: 0, vocabularies: [vocab]),
      ),
    );
  }

  Future<void> requestPermissions() async {
    final android = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Loads the vocabulary pool based on user settings from SharedPreferences.
  static Future<List<Vocabulary>> loadPool({
    required List<String> popularity,
    required List<String> topics,
    bool excludeKnown = true,
  }) async {
    if (topics.isNotEmpty) {
      return CsvService.loadSpecificTopicsVocabulary(
          topics, levelFilter: popularity, excludeKnown: excludeKnown);
    }
    return CsvService.loadSpecificPopularityVocabulary(
        popularity, excludeKnown: excludeKnown);
  }

  Future<void> scheduleVocabularyNotifications({
    required List<Vocabulary> pool,
    required int intervalMinutes,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    await cancelAllNotifications();
    if (pool.isEmpty || intervalMinutes <= 0) return;

    final now      = tz.TZDateTime.now(tz.local);
    final count    = min(Platform.isAndroid ? 100 : 64, pool.length);
    final shuffled = List.of(pool)..shuffle();

    final startMins = startTime.hour * 60 + startTime.minute;
    final endMins   = endTime.hour * 60 + endTime.minute;

    // Find first slot aligned to interval grid from midnight, after now
    final nowMins = now.hour * 60 + now.minute;
    int firstSlotMins = ((nowMins ~/ intervalMinutes) + 1) * intervalMinutes;
    if (firstSlotMins < startMins) {
      firstSlotMins = _alignedCeil(startMins, intervalMinutes);
    }

    tz.TZDateTime next;
    if (firstSlotMins >= endMins) {
      final slot = _alignedCeil(startMins, intervalMinutes);
      next = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1,
          slot ~/ 60, slot % 60);
    } else {
      next = tz.TZDateTime(tz.local, now.year, now.month, now.day,
          firstSlotMins ~/ 60, firstSlotMins % 60);
    }

    final futures       = <Future<void>>[];
    final logEntries    = <String>[];
    final widgetEntries = <String>[];

    for (int i = 0; i < count; i++) {
      if (i > 0) {
        next = next.add(Duration(minutes: intervalMinutes));
        final curMins = next.hour * 60 + next.minute;
        if (curMins >= endMins) {
          final slot = _alignedCeil(startMins, intervalMinutes);
          next = tz.TZDateTime(tz.local, next.year, next.month, next.day + 1,
              slot ~/ 60, slot % 60);
        } else if (curMins < startMins) {
          final slot = _alignedCeil(startMins, intervalMinutes);
          next = tz.TZDateTime(tz.local, next.year, next.month, next.day,
              slot ~/ 60, slot % 60);
        }
      }

      final v = shuffled[i];
      futures.add(_scheduleOne(i, v, next));
      logEntries.add('${next.millisecondsSinceEpoch}|${v.word}|${v.topic}');
      widgetEntries.add('${next.millisecondsSinceEpoch}|${v.word}|${v.translation}|${v.ipa}|${v.partOfSpeech}|${v.levels}|${v.topic}');
    }

    await Future.wait(futures);

    final prefs = await SharedPreferences.getInstance();

    // Save scheduled words directly to history (prepend, deduplicated)
    final existing = prefs.getStringList('notificationHistory') ?? [];
    final newEntries = shuffled.take(count)
        .map((v) => '${v.word}|${v.topic}')
        .where((e) => !existing.contains(e))
        .toList();
    final merged = [...newEntries, ...existing];
    if (merged.length > 500) merged.length = 500;
    await prefs.setStringList('notificationHistory', merged);

    // Persist schedule log for widget updates on app-open
    await prefs.setStringList('notificationScheduleLog', logEntries);

    // Save full widget schedule for native alarm receiver
    await HomeWidget.saveWidgetData<String>(
        'widgetScheduleEntries', widgetEntries.join(','));

    // Schedule first native alarm for widget auto-update
    if (Platform.isAndroid && widgetEntries.isNotEmpty) {
      final firstMs = int.tryParse(widgetEntries[0].split('|')[0]);
      if (firstMs != null) {
        try {
          await const MethodChannel('com.nguyenphuduc.eled/widget_alarm')
              .invokeMethod('scheduleFirst', {'atMs': firstMs});
        } catch (_) {}
      }
    }

    // Update widget immediately with first upcoming word
    if (logEntries.isNotEmpty) {
      try {
        await HomeWidget.saveWidgetData<String>('word', shuffled[0].word);
        await HomeWidget.saveWidgetData<String>('translation', shuffled[0].translation);
        await HomeWidget.saveWidgetData<String>('ipa', shuffled[0].ipa);
        await HomeWidget.saveWidgetData<String>('pos', shuffled[0].partOfSpeech);
        await HomeWidget.saveWidgetData<String>('levels', shuffled[0].levels);
        await HomeWidget.saveWidgetData<String>('topic', shuffled[0].topic);
        await HomeWidget.updateWidget(name: 'VocabularyWidgetProvider');
      } catch (_) {}
    }
  }

  /// Called on app open — finds fired notifications in the log, updates history + widget.
  static Future<void> processScheduleLog() async {
    final prefs = await SharedPreferences.getInstance();

    // Merge native history written by WidgetUpdateReceiver (no app needed)
    final nativePending = prefs.getString('nativeHistoryPending') ?? '';
    if (nativePending.isNotEmpty) {
      final nativeEntries = nativePending.split('\n').where((e) => e.isNotEmpty).toList();
      if (nativeEntries.isNotEmpty) {
        final history = prefs.getStringList('notificationHistory') ?? [];
        for (final entry in nativeEntries) {
          final word = entry.split('|')[0];
          history.removeWhere((e) => e == word || e.startsWith('$word|'));
          history.insert(0, entry);
        }
        if (history.length > 500) history.length = 500;
        await prefs.setStringList('notificationHistory', history);
        await prefs.remove('nativeHistoryPending');
      }
    }

    final log = prefs.getStringList('notificationScheduleLog') ?? [];
    if (log.isEmpty) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final lastProcessed = prefs.getInt('notificationScheduleLastProcessed') ?? 0;

    String? latestWord;
    final history = prefs.getStringList('notificationHistory') ?? [];
    bool historyChanged = false;

    for (final entry in log) {
      final parts = entry.split('|');
      if (parts.length < 3) continue;
      final ms = int.tryParse(parts[0]) ?? 0;
      if (ms <= lastProcessed || ms > nowMs) continue;

      final word  = parts[1];
      final topic = parts[2];
      history.removeWhere((e) => e == word || e.startsWith('$word|'));
      history.insert(0, '$word|$topic');
      historyChanged = true;
      latestWord = word;
    }

    if (history.length > 500) history.length = 500;
    if (historyChanged) {
      await prefs.setStringList('notificationHistory', history);
      await prefs.setInt('notificationScheduleLastProcessed', nowMs);
    }

    if (latestWord != null) {
      try {
        final allVocab = await CsvService.loadAllVocabulary(excludeKnown: false);
        final match = allVocab.where((v) =>
            v.word.trim().toLowerCase() == latestWord!.trim().toLowerCase());
        if (match.isNotEmpty) {
          final v = match.first;
          await HomeWidget.saveWidgetData<String>('word', v.word);
          await HomeWidget.saveWidgetData<String>('translation', v.translation);
          await HomeWidget.saveWidgetData<String>('ipa', v.ipa);
          await HomeWidget.saveWidgetData<String>('pos', v.partOfSpeech);
          await HomeWidget.saveWidgetData<String>('levels', v.levels);
          await HomeWidget.saveWidgetData<String>('topic', v.topic);
          await HomeWidget.updateWidget(name: 'VocabularyWidgetProvider');
        }
      } catch (_) {}
    }
  }

  static int _alignedCeil(int minutes, int interval) {
    final aligned = (minutes ~/ interval) * interval;
    return aligned >= minutes ? aligned : aligned + interval;
  }

  Future<void> _scheduleOne(int id, Vocabulary vocab, tz.TZDateTime at) async {
    Future<void> schedule(AndroidScheduleMode mode) =>
        flutterLocalNotificationsPlugin.zonedSchedule(
          id: id,
          title: vocab.word.toUpperCase(),
          body: '${vocab.translation} - ${vocab.partOfSpeech}',
          scheduledDate: at,
          notificationDetails: const NotificationDetails(android: kAndroidChannel),
          androidScheduleMode: mode,
          payload: '${vocab.word}|${vocab.topic}',
        );
    try {
      await schedule(AndroidScheduleMode.exactAllowWhileIdle);
    } catch (_) {
      await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }
}
