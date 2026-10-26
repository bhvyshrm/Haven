import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    if (kIsWeb) {
      _initialized = true;
      return;
    }

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notifications.initialize(settings: initSettings);
      _initialized = true;
    } catch (e) {
      debugPrint('Notification initialization exception: $e');
      _initialized = true;
    }
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    await init();

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidImpl = _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final granted = await androidImpl?.requestNotificationsPermission();
        return granted ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosImpl = _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final granted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macosImpl = _notifications
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
        final granted = await macosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return false;
  }

  Future<void> scheduleDailyJournalReminder(int hour, int minute) async {
    if (kIsWeb) return;
    await init();

    try {
      await _notifications.cancel(id: 101);
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'haven_journal_channel',
          'Haven Journal Reminders',
          channelDescription: 'Daily evening quiet reflection reminder',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

      await _notifications.zonedSchedule(
        id: 101,
        title: 'Haven',
        body: 'Time for a quiet moment of reflection today.',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule daily reminder: $e');
    }
  }

  Future<void> scheduleMondayPlanReminder() async {
    if (kIsWeb) return;
    await init();

    try {
      await _notifications.cancel(id: 102);
      final now = tz.TZDateTime.now(tz.local);
      // Next Monday 9:00 AM
      int daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
      if (daysUntilMonday == 0 && now.hour >= 9) {
        daysUntilMonday = 7;
      }
      final scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + daysUntilMonday,
        9,
        0,
      );

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'haven_planner_channel',
          'Haven Weekly Planner',
          channelDescription: 'Monday morning week intention reminder',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

      await _notifications.zonedSchedule(
        id: 102,
        title: 'Haven Weekly Plan',
        body: 'Set your quiet intentions and priorities for the week ahead.',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint('Failed to schedule Monday reminder: $e');
    }
  }

  Future<void> scheduleSundayReviewReminder() async {
    if (kIsWeb) return;
    await init();

    try {
      await _notifications.cancel(id: 103);
      final now = tz.TZDateTime.now(tz.local);
      // Next Sunday 7:00 PM (19:00)
      int daysUntilSunday = (DateTime.sunday - now.weekday + 7) % 7;
      if (daysUntilSunday == 0 && now.hour >= 19) {
        daysUntilSunday = 7;
      }
      final scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + daysUntilSunday,
        19,
        0,
      );

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'haven_review_channel',
          'Haven Weekly Review',
          channelDescription: 'Sunday evening reflection review reminder',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

      await _notifications.zonedSchedule(
        id: 103,
        title: 'Haven Sunday Review',
        body: 'How did this week feel? Take five minutes to review what went well.',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint('Failed to schedule Sunday reminder: $e');
    }
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    try {
      await _notifications.cancelAll();
    } catch (_) {}
  }
}
