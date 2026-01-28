import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. طلب إذن المستخدم (مهم جداً لتظهر الإشعارات)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. الحصول على التوكن (اختياري، يظهر في الـ Console عندك للتأكد من الربط)
    String? token = await _fcm.getToken();
    print("Device Token: $token");

    // 3. الاستماع للإشعارات أثناء فتح التطبيق
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("وصل إشعار والتطبيق مفتوح: ${message.notification?.title}");
    });
  }
}