import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// دالة الخلفية (Background Handler)
/// من أفضل الممارسات إبقاؤها خارج الكلاس لضمان عملها في مسار معالجة (Isolate) منفصل 
/// حتى لو كان التطبيق مغلقاً تماماً.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

@lazySingleton
class PushNotificationService {
  final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _notifKey = 'notifications_enabled';

  PushNotificationService(this._fcm);

  Future<void> initNotifications() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
bool isEnabled = await isNotificationsEnabled();
      if (isEnabled) {
        await _fcm.subscribeToTopic('all_users');
      }      await _initLocalNotifications();
      _setupMessageHandlers();
    }
  }
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidInitSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );
    await _localNotifications.initialize(
      settings: initSettings, 
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('تم النقر على الإشعار المحلي: ${response.payload}');
      },
    );
  }
  Future<bool> isNotificationsEnabled() async {
    String? value = await _storage.read(key: _notifKey);
    return value != 'false';
  }
Future<void> toggleNotifications(bool enable) async {
    try {
      if (enable) {
        await _fcm.subscribeToTopic('all_users');
        await _storage.write(key: _notifKey, value: 'true');
        debugPrint('تم تفعيل الإشعارات والاشتراك في all_users');
      } else {
        await _fcm.unsubscribeFromTopic('all_users');
        await _storage.write(key: _notifKey, value: 'false');
        debugPrint('تم إيقاف الإشعارات وإلغاء الاشتراك من all_users');
      }
    } catch (e) {
      debugPrint('خطأ أثناء تغيير حالة الإشعارات: $e');
    }
  }
  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'هذه القناة مخصصة للإشعارات المهمة',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
           
          ),
          payload: message.data['route'], 
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationClick(message);
      }
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  void _handleNotificationClick(RemoteMessage message) {
    final String? route = message.data['route'];
    if (route != null) {
      debugPrint('Navigating to $route');
    }
  }
}