import 'package:app_links/app_links.dart';
import 'package:diplomaapp/main.dart';
import 'package:diplomaapp/src/core/navigation/splash_page.dart';
import 'package:diplomaapp/src/core/startup_intent.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class StartupService {
  Uri? _lastHandledUri;

  Future<void> init() async {
    try {
      final initialUri = await AppLinks().getInitialLink();
      if (initialUri != null) {
        _queueUri(initialUri);
      }
    } catch (e) {
      Logger().e("Failed to get initial link: $e");
    }

    AppLinks().uriLinkStream.listen((uri) {
      final supportedPaths = ['/reset-password', '/new-user'];
      if (!supportedPaths.contains(uri.path)) {
        Logger().d("Ignoring internal intent/unsupported path: ${uri.path}");
        return;
      }

      if (_lastHandledUri != null && _lastHandledUri == uri) return;

      _queueUri(uri);
    });

    handleNotificationLaunch();
  }

  static Future<void> handleNotificationLaunch() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      StartupIntent.source = AppLaunchSource.notification;
      StartupIntent.payload = initialMessage.data;
    }
  }

  void _queueUri(Uri uri) {
    _lastHandledUri = uri;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        navigateFromUri(uri.path, uri.queryParameters);
      } else {
        await Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 50));
          final nav = navigatorKey.currentState;
          if (nav != null) {
            navigateFromUri(uri.path, uri.queryParameters);
            return false;
          }
          return true;
        });
      }
    });
  }
}
