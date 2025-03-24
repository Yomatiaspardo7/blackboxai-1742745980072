import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/user_profile.dart';

class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  NotificationService() {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    notifyListeners();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Manejar la interacción con la notificación
    debugPrint('Notificación tocada: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    if (!_isInitialized) await _init();

    final androidPermissions = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    final iosPermissions = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return androidPermissions ?? false || iosPermissions ?? false;
  }

  Future<void> scheduleBreathingReminder({
    required DateTime scheduledDate,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) await _init();

    await _notifications.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'breathing_reminders',
          'Recordatorios de Respiración',
          channelDescription: 'Recordatorios para ejercicios de respiración',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF57B4BA),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleStressCheckReminder({
    required DateTime scheduledDate,
  }) async {
    if (!_isInitialized) await _init();

    await _notifications.zonedSchedule(
      1,
      '¿Cómo te sientes?',
      'Es hora de revisar tus niveles de estrés',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'stress_check',
          'Revisión de Estrés',
          channelDescription: 'Recordatorios para revisar niveles de estrés',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF57B4BA),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleMindfulnessReminder({
    required DateTime scheduledDate,
    required String exerciseTitle,
  }) async {
    if (!_isInitialized) await _init();

    await _notifications.zonedSchedule(
      2,
      'Momento de Mindfulness',
      'Es hora de tu ejercicio: $exerciseTitle',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mindfulness_reminders',
          'Recordatorios de Mindfulness',
          channelDescription: 'Recordatorios para ejercicios de mindfulness',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF57B4BA),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleHighStressAlert({
    required HealthMetrics metrics,
  }) async {
    if (!_isInitialized) await _init();

    if (metrics.stressLevel > 7) {
      await _notifications.show(
        3,
        'Niveles de Estrés Elevados',
        'Detectamos niveles altos de estrés. ¿Te gustaría hacer un ejercicio de respiración?',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'stress_alerts',
            'Alertas de Estrés',
            channelDescription: 'Alertas para niveles altos de estrés',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFFFE4F2D),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await _init();
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) await _init();
    await _notifications.cancel(id);
  }

  Future<void> setupDailyReminders(MindfulnessPreferences preferences) async {
    if (!_isInitialized) await _init();

    // Cancelar recordatorios existentes
    await cancelAllNotifications();

    if (preferences.notifications['daily'] ?? false) {
      // Programar recordatorio diario de mindfulness
      final now = DateTime.now();
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        9, // 9:00 AM
        0,
      );

      await scheduleMindfulnessReminder(
        scheduledDate: scheduledTime,
        exerciseTitle: 'Meditación Matutina',
      );
    }

    if (preferences.notifications['stress'] ?? false) {
      // Programar revisiones de estrés
      final now = DateTime.now();
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        14, // 2:00 PM
        0,
      );

      await scheduleStressCheckReminder(
        scheduledDate: scheduledTime,
      );
    }
  }
}