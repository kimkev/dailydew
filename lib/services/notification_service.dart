import 'dart:io'; // Required for Platform check
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  // 1. Create a "Singleton" (one single instance of this service for the whole app)
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const int wateringSummaryNotificationId = 1000;

  // 2. INITIALIZE: This "wakes up" the notification system
  Future<void> init() async {
    tz.initializeTimeZones();

    // This detects your actual city (e.g., 'America/New_York')
    final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timeZoneInfo.identifier;
    // This tells the 'timezone' library to use that city for "tz.local"
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    // Settings for Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ); // Uses your app icon

    // Settings for iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false, // We will ask manually in onboarding
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      return await androidPlugin?.requestNotificationsPermission() ?? false;
    }

    if (Platform.isIOS || Platform.isMacOS) {
      return await _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }

    return false;
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificationsEnabled') ?? true;
  }

  Future<void> schedulePlantReminder({
    required int id,
    required String plantName,
    required int days,
  }) async {
    try {
      // 1. Fetch the user's preferred time from storage
      final prefs = await SharedPreferences.getInstance();
      final int hour = prefs.getInt('reminderHour') ?? 9; // Default to 9 AM
      final int minute = prefs.getInt('reminderMinute') ?? 0;

      final now = tz.TZDateTime.now(tz.local);

      // 2. Calculate the future day
      var scheduledDate = now.add(Duration(days: days));

      // 3. Use the USER'S SAVED TIME instead of hardcoded 9
      scheduledDate = tz.TZDateTime(
        tz.local,
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        hour,
        minute,
      );

      // 4. Handle edge case: If the scheduled time is technically in the past
      // (e.g., it's 10 AM and you scheduled for 8 AM today), move it to tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'Thirsty Plant! 🌱',
        body: '$plantName needs some water today.',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'plant_reminders',
            'Plant Care Reminders',
            importance: Importance.max,
            priority: Priority.high,
            // --- ADD THESE TWO LINES FOR ANDROID ---
            groupKey: 'com.kimkev.plant_tracker.WATER_GROUP',
            setAsGroupSummary:
                false, // Each plant is an individual item in the stack
          ),
          iOS: DarwinNotificationDetails(
            // --- ADD THIS LINE FOR iOS ---
            threadIdentifier: 'plant_reminders_group',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Notification scheduling failed: $e');
    }
  }

  Future<void> scheduleWateringSummary({
    required List<String> plantNames,
    required int days,
  }) async {
    if (plantNames.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hour = prefs.getInt('reminderHour') ?? 9;
      final minute = prefs.getInt('reminderMinute') ?? 0;

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = now.add(Duration(days: days));

      scheduledDate = tz.TZDateTime(
        tz.local,
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final body = plantNames.length == 1
          ? '${plantNames.first} needs some water today.'
          : '${plantNames.join(', ')} need water today.';

      await _notificationsPlugin.zonedSchedule(
        id: wateringSummaryNotificationId,
        title: plantNames.length == 1
            ? 'Thirsty Plant! 🌱'
            : '${plantNames.length} Plants Need Water 💧',
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'plant_reminders',
            'Plant Care Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            threadIdentifier: 'plant_reminders_group',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Watering summary scheduling failed: $e');
    }
  }

  Future<void> scheduleReminderForCurrentlyThirstyPlants({
    required List<String> plantNames,
  }) async {
    if (plantNames.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hour = prefs.getInt('reminderHour') ?? 9;
      final minute = prefs.getInt('reminderMinute') ?? 0;

      final now = tz.TZDateTime.now(tz.local);

      // Today at the user-selected reminder time.
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If today's selected time has passed, schedule tomorrow instead.
      if (!scheduledDate.isAfter(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final title = plantNames.length == 1
          ? 'Thirsty Plant! 🌱'
          : '${plantNames.length} Plants Need Water 💧';

      final body = plantNames.length == 1
          ? '${plantNames.first} needs some water today.'
          : '${plantNames.join(', ')} need water today.';

      await _notificationsPlugin.zonedSchedule(
        id: wateringSummaryNotificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'plant_reminders',
            'Plant Care Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            threadIdentifier: 'plant_reminders_group',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Thirsty-plant reminder scheduling failed: $e');
    }
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'plant_reminders',
          'Plant Care Reminders',
          importance: Importance.max,
          priority: Priority.high,
          groupKey: 'com.kimkev.plant_tracker.WATER_GROUP',
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
