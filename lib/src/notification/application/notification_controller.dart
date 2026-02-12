import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/notification/data/notification_repository.dart';
import 'package:diplomaapp/src/notification/domain/app_notification.dart';
import 'package:diplomaapp/src/services/firebase_api.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/data/slack_repository.dart';
import 'package:diplomaapp/src/shared/domain/slack_message.dart';

class NotificationController {
  final nRepo = getIt<NotificationRepository>();
  final sRepo = getIt<SlackRepository>();

  final fcm = getIt<FirebaseAPI>().fcmToken!;
  final user = getIt<UserService>().currentUser!;

  Future<void> notificationResponse(AppNotification n, bool suitable) async {
    await sRepo.sendMessage(
      SlackMessage(
        userId: user.id,
        fcmToken: fcm,
        threadTS: n.threadTs,
        channel: "notification",
        title:
            "${user.firstName} ${user.lastName} ${suitable ? "ustreza" : "neustreza"}",
        body: "${n.title}\n\n${n.body}",
      ),
    );

    await nRepo.setSuitable(n.linkId, user.id, false);
  }
}
