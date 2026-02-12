import 'dart:convert';
import 'package:diplomaapp/src/core/navigation/splash_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/data/encrypted_token_repository.dart';
import 'package:diplomaapp/src/shared/domain/account.dart';
import 'package:diplomaapp/src/shared/domain/token.dart';
import 'package:logger/logger.dart';

class FirebaseAPI {
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final enTokenRepo = getIt<EncryptedTokenRepository>();

  final AndroidNotificationChannel _androidChannel =
      const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.defaultImportance,
  );

  Future<void> bootstrapNotifications() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await _initLocalNotifications();
    await _initPushNotifications();

    final launchDetails =
        await _localNotifications.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails?.notificationResponse?.payload;
      if (payload != null) {
        await processNotification(jsonDecode(payload));
      }
    }
  }

  Future<void> syncNotificationToken({Account? account}) async {
    final acc = account ?? getIt<UserService>().currentAccount;
    Logger().e(acc?.toJson());
    if (acc == null) return;

    await _firebaseMessaging.requestPermission();

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      _saveToBackend(acc.id!, newToken);
    });

    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      _fcmToken = token;
      await _saveToBackend(acc.id!, token);
    }
  }

  Future<void> _saveToBackend(int accId, String token) async {
    var expiresAt = DateTime.now().add(Duration(days: 60));
    await enTokenRepo.saveToken(Token(
      accId: accId,
      token: token,
      type: "FCM",
      expriesAt: expiresAt,
    ));
  }

  Future<void> _initPushNotifications() async {
    final langCode = getIt<LanguageService>().current.code;
    _firebaseMessaging.getInitialMessage().then((msg) async {
      if (msg == null) return;

      await processNotification(msg.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((msg) async {
      return await processNotification(msg.data);
    });

    FirebaseMessaging.onMessage.listen((msg) async {
      final json = msg.data;

      final translationsJson =
          jsonDecode(json['translations']) as Map<String, dynamic>;
      final translation =
          translationsJson[langCode] ?? translationsJson['en'] ?? {};

      _localNotifications.show(
        msg.data.hashCode,
        translation["title"],
        translation["body"],
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            icon: '@drawable/logo_gold',
          ),
        ),
        payload: jsonEncode(json),
      );
    });
  }

  Future<void> _initLocalNotifications() async {
    const settings = InitializationSettings(
      iOS: DarwinInitializationSettings(),
      android: AndroidInitializationSettings('@drawable/ic_launcher'),
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) async {
        if (response.payload == null) return;

        await processNotification(jsonDecode(response.payload!));
      },
    );
  }
}
