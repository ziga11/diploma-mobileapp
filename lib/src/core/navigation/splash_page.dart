import 'dart:convert';
import 'package:diplomaapp/src/notification/data/notification_repository.dart';
import 'package:diplomaapp/src/shared/data/user_repository.dart';
import 'package:flutter/material.dart';

import 'package:diplomaapp/main.dart';
import 'package:diplomaapp/src/auth/presentation/reset_password_page.dart';
import 'package:diplomaapp/src/auth/presentation/set_password_page.dart';
import 'package:diplomaapp/src/core/startup_intent.dart';
import 'package:diplomaapp/src/document/data/document_repository.dart';
import 'package:diplomaapp/src/document/presentation/doc_viewer.dart';
import 'package:diplomaapp/src/employment/presentation/employment.dart';
import 'package:diplomaapp/src/notification/domain/app_notification.dart';
import 'package:diplomaapp/src/notification/presentation/notification_page.dart';
import 'package:diplomaapp/src/obligation/presentation/obligation_list_page.dart';
import 'package:diplomaapp/src/profile/presentation/profile.dart';
import 'package:diplomaapp/src/request/presentation/message_page.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/auth/presentation/login_page.dart';
import 'package:diplomaapp/src/core/navigation/menu.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/profile/presentation/profile_preview.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:logger/logger.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      while (navigatorKey.currentState == null ||
          !getIt<UserService>().initialized) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      if (context.mounted) _resolveStartup(context);
    });

    return const SizedBox();
  }

  void _resolveStartup(BuildContext context) {
    if (StartupIntent.handled) return;
    StartupIntent.handled = true;

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != null && currentRoute != '/') {
      Logger().w("SplashPage logic blocked: App is already on $currentRoute");
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final navigator = Navigator.of(context);
      final userService = getIt<UserService>();

      while (!userService.initialized) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      switch (StartupIntent.source) {
        case AppLaunchSource.deepLink:
          final path = StartupIntent.payload!['uri'] as String;
          final query = StartupIntent.payload!['query'] as Map<String, String>;
          navigateFromUri(path, query);
          break;

        case AppLaunchSource.notification:
          final user = userService.currentUser;

          if (user == null) {
            navigator.pushReplacementNamed(LoginPage.route);
          }

          if (navigatorKey.currentState?.canPop() == false) {
            navigator.pushReplacementNamed(Menu.route);
          }

          return;

        default:
          final user = getIt<UserService>().currentUser;
          if (user == null) {
            navigator.pushReplacementNamed(LoginPage.route);
          } else if (user.group == "Registered") {
            navigator.pushReplacementNamed(ProfilePreviewPage.route);
          } else {
            navigator.pushReplacementNamed(Menu.route);
          }
      }
    });
  }
}

Future<void> processNotification(Map<String, dynamic> json) async {
  final userService = getIt<UserService>();

  while (!userService.initialized) {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  if (userService.currentUser == null) {
    return;
  }

  final langCode = getIt<LanguageService>().current.code;

  json["translations"] = jsonDecode(json["translations"]);

  bool toUpdate = json["update"] == "true";

  final notification = AppNotification.fromJson(json, langCode);
  final navPage = json["nav_page"] ?? "";
  final args = json["arguments"] ?? "";

  getIt<NotificationRepository>()
      .setRead(notification.linkId, userService.currentUser!.id);

  if (toUpdate) {
    var user =
        await getIt<UserRepository>().getUserById(userService.currentUser!.id);
    var acc = await getIt<UserRepository>()
        .accountById(userService.currentAccount!.id!);

    userService.setSession(user, acc);
  }

  await navigateFromNotification(notification, navPage, args);
}

Future<void> navigateFromNotification(
    AppNotification notification, String navPage, dynamic args) async {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final state = navigatorKey.currentState;
    if (state == null) return;

    String? currentRoute;
    navigatorKey.currentState?.popUntil((route) {
      currentRoute = route.settings.name;
      return true;
    });

    if (getIt<UserService>().currentUser == null) {
      state.pushReplacementNamed(LoginPage.route);
      return;
    }

    switch (navPage) {
      case ListObligationsPage.route:
        if (currentRoute == navPage) return;

        navigatorKey.currentState?.pushNamed(
          ListObligationsPage.route,
          arguments: args,
        );
        break;

      case MessagePage.route:
        navigatorKey.currentState?.pushNamed(
          MessagePage.route,
          arguments: args,
        );
        break;

      case ProfilePage.route:
        if (currentRoute == navPage) return;

        navigatorKey.currentState?.pushNamed(
          ProfilePage.route,
          arguments: args,
        );
        break;

      case EmploymentPage.route:
        if (currentRoute == navPage) return;

        navigatorKey.currentState?.pushNamed(
          EmploymentPage.route,
          arguments: args,
        );
        break;

      case DocumentViewerPage.route:
        int? dId = int.tryParse(args);
        if (dId == null) return;

        var doc = await getIt<DocumentRepository>().fetchDocById(dId);

        navigatorKey.currentState?.pushNamed(
          DocumentViewerPage.route,
          arguments: doc,
        );
        break;

      default:
        navigatorKey.currentState?.pushNamed(
          NotificationPage.route,
          arguments: notification,
        );
    }
  });
}

void navigateFromUri(String path, Map<String, dynamic> query) {
  final navigator = navigatorKey.currentState;
  if (navigator == null) return;

  if (path == '/reset-password') {
    final email = query['email'];
    final token = query['token'];
    if (token == null || email == null) return;

    navigator.pushNamed(ResetPasswordPage.route, arguments: [email, token]);
  }

  if (path == '/new-user') {
    final token = query['token'];

    if (token != null) {
      navigator.pushNamed(SetPasswordPage.route, arguments: token);
    }
  }
}
