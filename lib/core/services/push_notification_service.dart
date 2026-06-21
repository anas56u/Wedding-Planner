import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  
  // إنشاء نسخة من Local Notifications للتعامل مع الإشعارات والتطبيق مفتوح
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  PushNotificationService(this._fcm);

  Future<void> initNotifications() async {
    // 1. طلب صلاحيات فايربيس (أساسي لأندرويد 13+ و iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      
      // 2. الاشتراك في الـ Topic لإرسال إشعارات جماعية
      await _fcm.subscribeToTopic('all_users');
      
      // 3. تهيئة الإشعارات المحلية قبل استدعاء الـ Listeners
      await _initLocalNotifications();
      
      // 4. تشغيل المستمعين (Listeners) لحالات التطبيق المختلفة
      _setupMessageHandlers();
    }
  }

  // دالة تهيئة الإشعارات المحلية (Local Notifications)
  Future<void> _initLocalNotifications() async {
    // إعداد أيقونة الإشعار لأندرويد (يجب أن تكون الأيقونة موجودة في مجلد mipmap)
    const AndroidInitializationSettings androidInitSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // إعدادات iOS
    const DarwinInitializationSettings iosInitSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    // ✅ التعديل تم هنا: استخدام المعامل المسمى settings:
    await _localNotifications.initialize(
      // تمرير الإعدادات بالاسم الصحيح الذي تطلبه الحزمة الآن
      settings: initSettings, 
      
      // دالة الاستماع للنقر على الإشعار المحلي (والتطبيق مفتوح)
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('تم النقر على الإشعار المحلي: ${response.payload}');
        // هنا يمكنك لاحقاً توجيه المستخدم لصفحة معينة باستخدام الـ payload
      },
    );
  }

  void _setupMessageHandlers() {
    // أ. عند استلام إشعار والتطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // التأكد أن الرسالة تحتوي على إشعار مرئي وأن النظام هو أندرويد
     // التأكد أن الرسالة تحتوي على إشعار مرئي وأن النظام هو أندرويد
      if (notification != null && android != null) {
        // عرض الإشعار المنبثق باستخدام Local Notifications (تم التحديث هنا)
        _localNotifications.show(
          id: notification.hashCode, // أضفنا id:
          title: notification.title, // أضفنا title:
          body: notification.body,   // أضفنا body:
          notificationDetails: const NotificationDetails( // أضفنا notificationDetails:
            android: AndroidNotificationDetails(
              'high_importance_channel', // معرف القناة
              'High Importance Notifications', // اسم القناة
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

    // ب. عند النقر على إشعار فايربيس (التطبيق في الخلفية)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    // ج. التعامل مع الإشعارات عندما يكون التطبيق مغلقاً تماماً ويتم فتحه عبر النقر على الإشعار
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationClick(message);
      }
    });

    // د. ربط دالة استلام الإشعارات في الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // دالة موحدة للتعامل مع التوجيه (Routing) عند النقر على أي إشعار
  void _handleNotificationClick(RemoteMessage message) {
    final String? route = message.data['route'];
    if (route != null) {
      debugPrint('Navigating to $route');
      // لاحقاً: إضافة كود الـ Navigator.pushNamed أو ما شابه هنا
    }
  }
}