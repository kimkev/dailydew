import 'dart:io'; // Required for Platform check
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

  Future<void> checkPending() async {
    final List<PendingNotificationRequest> pending = await _notificationsPlugin
        .pendingNotificationRequests();
    print("PENDING COUNT: ${pending.length}");
    for (var p in pending) {
      print("Pending ID: ${p.id} | Title: ${p.title}");
    }
  }

  Future<void> requestPermissions() async {
    // 1. Android logic
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
    }

    // 2. iOS/MacOS logic (THE SAFE WAY)
    // Instead of naming the Plugin type, we use the universal "requestPermissions"
    // from the main plugin if we are on a Darwin platform.
    if (Platform.isIOS || Platform.isMacOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
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
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      print(
        "SUCCESS: Scheduled for $hour:$minute on ${scheduledDate.day}/${scheduledDate.month}",
      );
    } catch (e) {
      print("ERROR: Could not schedule: $e");
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
          'Plant Reminders',
          importance: Importance.max,
          priority: Priority.high,
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
