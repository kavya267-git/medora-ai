import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Helper to convert TimeOfDay to tz.TZDateTime
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // Initialize notifications
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medora_channel',
      'Medora Notifications',
      channelDescription: 'Important health reminders and alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Schedule notification for specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medora_scheduled_channel',
      'Medora Scheduled Reminders',
      channelDescription: 'Scheduled health reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Removed dateInterpretation
    );
  }

  // Schedule daily medication reminder
  Future<void> scheduleDailyMedicationReminder({
    required int id,
    required String medicationName,
    required TimeOfDay time,
    String? dosage,
  }) async {
    final scheduledTime = _nextInstanceOfTime(time);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medora_medication_channel',
      'Medora Medication Reminders',
      channelDescription: 'Daily medication reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      '💊 Medication Reminder',
      'Time to take your $medicationName${dosage != null ? ' ($dosage)' : ''}',
      scheduledTime,
      details,
      payload: 'medication_reminder',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      // Removed dateInterpretation
    );
  }

  // Schedule BP measurement reminder
  Future<void> scheduleBPMeasurementReminder({
    required int id,
    required TimeOfDay time,
  }) async {
    final scheduledTime = _nextInstanceOfTime(time);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medora_health_channel',
      'Medora Health Tracking',
      channelDescription: 'Health measurement reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      id,
      '🩺 BP Measurement',
      'Time to check your blood pressure',
      scheduledTime,
      details,
      payload: 'bp_measurement',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      // Removed dateInterpretation
    );
  }

  // Schedule sugar measurement reminder
  Future<void> scheduleSugarMeasurementReminder({
    required int id,
    required TimeOfDay time,
    required String measurementType,
  }) async {
    final scheduledTime = _nextInstanceOfTime(time);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medora_health_channel',
      'Medora Health Tracking',
      channelDescription: 'Health measurement reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    String reminderText = '';
    switch (measurementType) {
      case 'fasting':
        reminderText = 'Time to check your fasting sugar level';
        break;
      case 'postMeal':
        reminderText = 'Time to check your post-meal sugar level';
        break;
      default:
        reminderText = 'Time to check your sugar level';
    }

    await _notifications.zonedSchedule(
      id,
      '🩸 Sugar Measurement',
      reminderText,
      scheduledTime,
      details,
      payload: 'sugar_measurement',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      // Removed dateInterpretation
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Show SOS emergency notification
  Future<void> showSOSEmergencyNotification({
    required String userName,
    required String location,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medora_emergency_channel',
      'Medora Emergency Alerts',
      channelDescription: 'Emergency SOS alerts',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      9999, // Emergency ID
      '🚨 EMERGENCY ALERT 🚨',
      '$userName needs immediate help! Location: $location',
      details,
      payload: 'sos_emergency',
    );
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final bool? result = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    return result ?? false;
  }
}