import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:day_in_bloom_fd_v1/features/authentication/service/kakao_auth_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class FCMService {
  static Future<void> init() async {
    await _requestPermission();
    await _initLocalNotifications();

    final fcmToken = await FirebaseMessaging.instance.getToken();
    final status = await FirebaseMessaging.instance.getNotificationSettings();

    if (status.authorizationStatus == AuthorizationStatus.authorized && fcmToken != null) {
      print('FCM Token: $fcmToken');
      await _sendTokenToLambda(fcmToken);
    } else {
      print('FCM Token not available');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('FCM Token refreshed: $newToken');
      await _sendTokenToLambda(newToken);
    });


    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  static Future<void> _sendTokenToLambda(String fcmToken) async {
    final kakaoUserId = await KakaoAuthService.getUserId();
    if (kakaoUserId == null) {
      print('kakaoUserId가 없습니다.');
      return;
    }

    final url = Uri.parse('https://1dzzkwh851.execute-api.ap-northeast-2.amazonaws.com/Prod/fcmToken');

    final data = {
      'kakaoUserId': kakaoUserId,
      'fcmToken': fcmToken,
      'platform': 'android',
    };

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Token successfully sent to Lambda');
    } else {
      print('Failed to send token to Lambda: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> _initLocalNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void _onForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.data}');
    if (message.notification != null) {
      flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel_id',
            '기본 채널',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  static Future<void> deleteTokenFromLambda() async {
    final kakaoUserId = await KakaoAuthService.getUserId();
    if (kakaoUserId == null) {
      print('kakaoUserId가 없습니다. 삭제 요청을 보낼 수 없습니다.');
      return;
    }

    final url = Uri.parse(
      'https://1dzzkwh851.execute-api.ap-northeast-2.amazonaws.com/Prod/fcmToken?kakaoUserId=$kakaoUserId',
    );

    print('Sending DELETE request to Lambda...');
    print('URL: $url');

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('FCM 토큰 삭제 성공');
      } else {
        print('FCM 토큰 삭제 실패');
      }
    } catch (e) {
      print('Exception during token delete: $e');
    }
  }


  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Background message: ${message.messageId}');
  }
}
