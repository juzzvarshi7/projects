import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final FlutterTts flutterTts = FlutterTts();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // background handler - keep minimal
  print('Handling a background message: \${message.messageId}');
}

class PushService {
  static final PushService _instance = PushService._internal();
  factory PushService() => _instance;
  PushService._internal();

  Future<void> init(BuildContext context) async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings =
        InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true, badge: true, sound: true, provisional: false);
    String? token = await messaging.getToken();
    debugPrint('FCM token: \$token');

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
      RemoteNotification? notification = msg.notification;
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification?.title ?? 'Message',
        notification?.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'principal_scheduler_channel',
            'Principal Scheduler',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      );

      final type = msg.data['type'] ?? '';
      final speak = (type == 'decision');
      if (speak) {
        final messageText = msg.data['voice_text'] ?? (notification?.body ?? 'You have an update');
        await flutterTts.setLanguage('en-US');
        await flutterTts.setSpeechRate(0.45);
        await flutterTts.speak(messageText);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // handle when app opened from notification
    });
  }
}
