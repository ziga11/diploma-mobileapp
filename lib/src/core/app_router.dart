import 'package:diplomaapp/src/document/domain/document.dart';
import 'package:diplomaapp/src/document/presentation/doc_viewer.dart';
import 'package:diplomaapp/src/employment/presentation/employment.dart';
import 'package:diplomaapp/src/notification/domain/app_notification.dart';
import 'package:diplomaapp/src/obligation/presentation/obligation_list_page.dart';
import 'package:diplomaapp/src/profile/presentation/profile_preview.dart';
import 'package:diplomaapp/src/request/presentation/list_requests_page.dart';
import 'package:diplomaapp/src/request/presentation/message_page.dart';
import 'package:flutter/material.dart';
import 'package:diplomaapp/src/auth/presentation/login_page.dart';
import 'package:diplomaapp/src/auth/presentation/reset_password_page.dart';
import 'package:diplomaapp/src/auth/presentation/set_password_page.dart';
import 'package:diplomaapp/src/core/navigation/menu.dart';
import 'package:diplomaapp/src/notification/presentation/notification_page.dart';
import 'package:diplomaapp/src/profile/presentation/profile.dart';
import 'package:logger/logger.dart';

class AppRouter {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case LoginPage.route:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case Menu.route:
        return MaterialPageRoute(
          builder: (_) => const Menu(),
          settings: settings,
        );

      case NotificationPage.route:
        final notification = settings.arguments as AppNotification;
        return MaterialPageRoute(
          builder: (_) => NotificationPage(
            appNotification: notification,
          ),
          settings: settings,
        );

      case ProfilePreviewPage.route:
        return MaterialPageRoute(
          builder: (_) => ProfilePreviewPage(),
          settings: settings,
        );

      case ResetPasswordPage.route:
        final args = settings.arguments as List;
        return MaterialPageRoute(
            builder: (_) => ResetPasswordPage(
                  email: args[0],
                  token: args[1],
                ),
            settings: settings);

      case SetPasswordPage.route:
        final token = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => SetPasswordPage(token: token),
          settings: settings,
        );

      case ProfilePage.route:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      case EmploymentPage.route:
        return MaterialPageRoute(
          builder: (_) => const EmploymentPage(),
          settings: settings,
        );

      case MessagePage.route:
        final rawArgs = settings.arguments;
        int? reqId = int.tryParse(rawArgs?.toString() ?? '');

        return MaterialPageRoute(
          builder: (_) => reqId != null
              ? MessagePage(
                  reqId: reqId,
                )
              : ListMessagesPage(),
          settings: settings,
        );

      case DocumentViewerPage.route:
        final doc = settings.arguments as Document;

        return MaterialPageRoute(
          builder: (_) {
            return DocumentViewerPage(document: doc);
          },
          settings: settings,
        );

      case ListObligationsPage.route:
        final oIdsString = settings.arguments as String;
        List<int> oIds =
            oIdsString.split(", ").map((e) => int.parse(e)).toList();

        return MaterialPageRoute(
          builder: (_) => ListObligationsPage(highlightedIds: oIds),
          settings: settings,
        );

      default:
        Logger().w("${settings.name} is not set, routing to login page");
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
    }
  }
}
