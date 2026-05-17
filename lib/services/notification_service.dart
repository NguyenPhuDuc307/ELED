import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import '../models/vocabulary.dart';
import '../services/csv_service.dart';
import '../services/update_service.dart';
import '../services/user_data_service.dart';
import '../screens/learning_screen.dart';
import '../utils/log.dart';
import '../main.dart';

// iOS-only notification channel (Android uses native VocabNotificationReceiver)
const _kIOSDetails = DarwinNotificationDetails();

// Native Android notification scheduling channel
const _kAndroidChannel = MethodChannel('com.nguyenphuduc.eled/notifications');

// Navigation channel — Kotlin sends openPayload when user taps a notification
const _kNavChannel = MethodChannel('com.nguyenphuduc.eled/nav');

// Separators for the persisted pool string (must match ScheduleEngine.kt).
const _kFieldSep = '';
const _kItemSep = '\n';

// Top-level handler — kept for iOS background actions (not used on Android)
@pragma('vm:entry-point')
Future<void> notificationBackgroundHandler(NotificationResponse response) async {}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName));

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
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );

    HomeWidget.widgetClicked.listen(_onWidgetTapped, onError: (_) {});
    HomeWidget.initiallyLaunchedFromHomeWidget()
        .then(_onWidgetTapped)
        .catchError((_) {});

    if (Platform.isAndroid) {
      _kNavChannel.setMethodCallHandler((call) async {
        if (call.method == 'openPayload') {
          final payload = call.arguments as String?;
          if (payload != null && payload.isNotEmpty) {
            await _onNotificationTapped(NotificationResponse(
              notificationResponseType: NotificationResponseType.selectedNotification,
              payload: payload,
            ));
          }
        }
      });
    }
  }

  static Future<void> _onWidgetTapped(Uri? uri) async {
    try {
      if (uri != null && uri.scheme == 'eled') {
        final payload = uri.queryParameters['payload'];
        if (payload != null && payload.isNotEmpty) {
          _onNotificationTapped(NotificationResponse(
            notificationResponseType: NotificationResponseType.selectedNotification,
            payload: payload,
          ));
        }
      }
    } catch (e, st) {
      logCaught(e, st, 'NotificationService._onWidgetTapped');
    }
  }

  /// Shows a system notification that a new app version is available.
  static Future<void> showUpdateNotification(UpdateInfo info) async {
    final plugin = NotificationService().flutterLocalNotificationsPlugin;
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'eled_update',
        'App Updates',
        importance: Importance.defaultImportance,
      );
      await plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
    await plugin.show(
      id: 99999,
      title: 'Update available — v${info.version}',
      body: 'Tap to download the latest version',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('eled_update', 'App Updates'),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'update:${info.apkUrl.isNotEmpty ? info.apkUrl : info.releaseUrl}',
    );
  }

  static Future<void> _onNotificationTapped(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    // Handle update notification tap — open download URL in browser
    if (payload.startsWith('update:')) {
      final url = payload.substring('update:'.length);
      if (url.isNotEmpty) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
      return;
    }

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

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('notificationHistory') ?? [];
      final entry = '${vocab.word}|${vocab.topic}';
      history.removeWhere((e) => e == vocab.word || e.startsWith('${vocab.word}|'));
      history.insert(0, entry);
      if (history.length > 500) history.length = 500;
      await prefs.setStringList('notificationHistory', history);
    } catch (e, st) {
      logCaught(e, st, 'NotificationService._onNotificationTapped:historyWrite');
    }

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
    if (Platform.isAndroid) {
      try {
        await _kAndroidChannel.invokeMethod('cancelAll');
      } catch (e, st) {
        logCaught(e, st, 'NotificationService.cancelAllNotifications:nativeCancel');
      }
      // Clear persisted pool/config so the watchdog & boot receiver stop re-arming.
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('vocabSchedulePool');
        await prefs.remove('vocabScheduleIntervalMinutes');
        await prefs.remove('vocabScheduleStartMinutes');
        await prefs.remove('vocabScheduleEndMinutes');
        await prefs.remove('vocabScheduleLatestMs');
        await prefs.remove('vocabScheduleLastFireMs');
        await prefs.remove('vocabSchedulePoolCursor');
      } catch (e, st) {
        logCaught(e, st, 'NotificationService.cancelAllNotifications:clearPrefs');
      }
    }
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Returns true if the user has already exempted the app from battery optimizations
  /// (or running on a pre-Marshmallow device where the API doesn't exist).
  Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      final v = await _kAndroidChannel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return v ?? false;
    } catch (e, st) {
      logCaught(e, st, 'NotificationService.isIgnoringBatteryOptimizations');
      return false;
    }
  }

  /// Shows the system "Allow app to run in background" prompt.
  Future<void> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return;
    try {
      await _kAndroidChannel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e, st) {
      logCaught(e, st, 'NotificationService.requestIgnoreBatteryOptimizations');
    }
  }

  /// Opens the OS "Battery optimization" settings list (fallback when the
  /// prompt above is unavailable, e.g. some OEM ROMs).
  Future<void> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _kAndroidChannel.invokeMethod('openBatteryOptimizationSettings');
    } catch (e, st) {
      logCaught(e, st, 'NotificationService.openBatteryOptimizationSettings');
    }
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

    final logEntries    = <String>[];
    final widgetEntries = <String>[];

    if (Platform.isAndroid) {
      // Persist the full shuffled pool + config so native code (rolling refill,
      // BootReceiver, WatchdogWorker) can keep the queue topped up after the
      // initial batch fires.
      await _persistAndroidConfig(
        pool: shuffled,
        intervalMinutes: intervalMinutes,
        startMins: startMins,
        endMins: endMins,
      );

      // Build batch for native scheduling
      final items = <Map<String, dynamic>>[];
      for (int i = 0; i < count; i++) {
        if (i > 0) {
          next = _advance(next, intervalMinutes, startMins, endMins);
        }
        final v = shuffled[i];
        items.add({
          'id': i,
          'word': v.word,
          'translation': v.translation,
          'pos': v.partOfSpeech,
          'topic': v.topic,
          'atMs': next.millisecondsSinceEpoch,
          'audioUrl': v.audioLink,
        });
        logEntries.add('${next.millisecondsSinceEpoch}|${v.word}|${v.topic}');
        widgetEntries.add('${next.millisecondsSinceEpoch}|${v.word}|${v.translation}|${v.ipa}|${v.partOfSpeech}|${v.levels}|${v.topic}');
      }
      try {
        await _kAndroidChannel.invokeMethod('scheduleAll', {'items': items});
      } catch (e, st) {
        logCaught(e, st, 'NotificationService.scheduleAll:nativeBatch');
      }
    } else {
      // iOS — use flutter_local_notifications
      final futures = <Future<void>>[];
      for (int i = 0; i < count; i++) {
        if (i > 0) {
          next = _advance(next, intervalMinutes, startMins, endMins);
        }
        final v = shuffled[i];
        futures.add(_scheduleIOS(i, v, next));
        logEntries.add('${next.millisecondsSinceEpoch}|${v.word}|${v.topic}');
        widgetEntries.add('${next.millisecondsSinceEpoch}|${v.word}|${v.translation}|${v.ipa}|${v.partOfSpeech}|${v.levels}|${v.topic}');
      }
      await Future.wait(futures);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notificationScheduleLog', logEntries);

    await HomeWidget.saveWidgetData<String>(
        'widgetScheduleEntries', widgetEntries.join(','));

    if (Platform.isAndroid && widgetEntries.isNotEmpty) {
      final firstMs = int.tryParse(widgetEntries[0].split('|')[0]);
      if (firstMs != null) {
        try {
          await const MethodChannel('com.nguyenphuduc.eled/widget_alarm')
              .invokeMethod('scheduleFirst', {'atMs': firstMs});
        } catch (e, st) {
          logCaught(e, st, 'NotificationService.scheduleAll:widgetAlarm');
        }
      }
    }

    if (logEntries.isNotEmpty) {
      try {
        await HomeWidget.saveWidgetData<String>('word', shuffled[0].word);
        await HomeWidget.saveWidgetData<String>('translation', shuffled[0].translation);
        await HomeWidget.saveWidgetData<String>('ipa', shuffled[0].ipa);
        await HomeWidget.saveWidgetData<String>('pos', shuffled[0].partOfSpeech);
        await HomeWidget.saveWidgetData<String>('levels', shuffled[0].levels);
        await HomeWidget.saveWidgetData<String>('topic', shuffled[0].topic);
        await HomeWidget.updateWidget(name: 'VocabularyWidgetProvider');
      } catch (e, st) {
        logCaught(e, st, 'NotificationService.scheduleAll:widgetData');
      }
    }
  }

  /// Called on app open — finds fired notifications in the log, updates history + widget.
  static Future<void> processScheduleLog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    // Merge words marked known via notification action while app was in background
    final pendingKnown = prefs.getString('nativePendingKnownWords') ?? '';
    if (pendingKnown.isNotEmpty) {
      await prefs.remove('nativePendingKnownWords');
      for (final word in pendingKnown.split('\n').where((w) => w.isNotEmpty)) {
        await UserDataService().addKnownWord(word);
      }
    }

    // Merge native notification tap payload saved by MainActivity.saveNativePayload()
    final nativePayload = prefs.getString('nativeNotificationPayload');
    if (nativePayload != null && nativePayload.isNotEmpty) {
      await prefs.remove('nativeNotificationPayload');
      // If navigator is ready (app already running), navigate immediately.
      // Otherwise store for MenuScreen.initState to consume on first build.
      if (globalNavigatorKey.currentState != null) {
        await _onNotificationTapped(NotificationResponse(
          notificationResponseType: NotificationResponseType.selectedNotification,
          payload: nativePayload,
        ));
      } else {
        pendingNotificationPayload ??= nativePayload;
      }
    }

    // Merge native history written by WidgetUpdateReceiver (no app needed)
    final nativeHistoryPending = prefs.getString('nativeHistoryPending') ?? '';
    if (nativeHistoryPending.isNotEmpty) {
      final nativeEntries = nativeHistoryPending.split('\n').where((e) => e.isNotEmpty).toList();
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
      } catch (e, st) {
        logCaught(e, st, 'NotificationService.processScheduleLog:widgetData');
      }
    }
  }

  static int _alignedCeil(int minutes, int interval) {
    final aligned = (minutes ~/ interval) * interval;
    return aligned >= minutes ? aligned : aligned + interval;
  }

  static tz.TZDateTime _advance(
      tz.TZDateTime current, int intervalMinutes, int startMins, int endMins) {
    var next = current.add(Duration(minutes: intervalMinutes));
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
    return next;
  }

  /// Persists the schedule pool + window to SharedPreferences using the keys
  /// expected by [ScheduleEngine] on the Kotlin side. The native rolling refill,
  /// boot receiver and watchdog all read from these keys.
  Future<void> _persistAndroidConfig({
    required List<Vocabulary> pool,
    required int intervalMinutes,
    required int startMins,
    required int endMins,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = pool.map((v) => [
          v.word,
          v.translation,
          v.partOfSpeech,
          v.topic,
          v.audioLink,
          v.ipa,
          v.levels,
        ].join(_kFieldSep)).join(_kItemSep);

    await prefs.setString('vocabSchedulePool', encoded);
    await prefs.setInt('vocabScheduleIntervalMinutes', intervalMinutes);
    await prefs.setInt('vocabScheduleStartMinutes', startMins);
    await prefs.setInt('vocabScheduleEndMinutes', endMins);
    // Reset fire/cursor markers for the new schedule. Native scheduleAll handler
    // will fill latestMs + poolCursor based on the actual batch it just queued.
    await prefs.remove('vocabScheduleLastFireMs');
  }

  Future<void> _scheduleIOS(int id, Vocabulary vocab, tz.TZDateTime at) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: vocab.word.toUpperCase(),
      body: '${vocab.translation} - ${vocab.partOfSpeech}',
      scheduledDate: at,
      notificationDetails: const NotificationDetails(iOS: _kIOSDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '${vocab.word}|${vocab.topic}',
    );
  }
}
