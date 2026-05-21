import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static const _primary = Color(0xFF008088);

  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'meeting_reminders',
          channelName: 'Meeting Reminders',
          channelDescription: 'Reminders for upcoming meetings',
          importance: NotificationImportance.High,
          defaultColor: _primary,
          ledColor: _primary,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'meeting_alarms',
          channelName: 'Meeting Alarms',
          channelDescription: 'Alarm-style alerts at meeting time',
          importance: NotificationImportance.Max,
          defaultColor: _primary,
          ledColor: _primary,
          playSound: true,
          enableVibration: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelKey: 'followup',
          channelName: 'Follow-ups',
          channelDescription: 'Follow-up reminders',
          importance: NotificationImportance.Default,
          defaultColor: _primary,
        ),
      ],
    );
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  static Future<void> scheduleMeetingReminder({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    bool alarm = false,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: alarm ? 'meeting_alarms' : 'meeting_reminders',
        title: alarm ? 'MEETING NOW: $title' : title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: alarm,
        fullScreenIntent: alarm,
        criticalAlert: alarm,
        category: alarm ? NotificationCategory.Alarm : NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar.fromDate(date: at, allowWhileIdle: true, preciseAlarm: true),
    );
  }

  static Future<void> showImmediate(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        channelKey: 'meeting_reminders',
        title: title,
        body: body,
      ),
    );
  }
}
