import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/document/data/document_repository.dart';
import 'package:diplomaapp/src/request/data/request_repository.dart';
import 'package:diplomaapp/src/request/domain/request.dart';
import 'package:diplomaapp/src/request/domain/request_type_enum.dart';
import 'package:diplomaapp/src/services/firebase_api.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/data/slack_repository.dart';
import 'package:diplomaapp/src/shared/domain/slack_file.dart';
import 'package:diplomaapp/src/shared/domain/slack_message.dart';
import 'package:logger/logger.dart';

class RequestController {
  final fcm = getIt<FirebaseAPI>().fcmToken!;
  final langService = getIt<LanguageService>();
  final userService = getIt<UserService>();

  final sRepo = getIt<SlackRepository>();
  final mRepo = getIt<MessageRepository>();
  final dRepo = getIt<DocumentRepository>();

  Future<int> sendRequest(
      {required RequestType? requestType,
      required Message msg,
      List<PlatformFile>? files}) async {
    throwIf(requestType == null, "chooseRequest");
    throwIf(requestType!.isFileRequired && files == null, "fileRequired");

    final user = userService.currentUser!;

    try {
      final title = msg.getMessageContent().title;
      final fileUploads = files?.map((file) async {
        var doc = await dRepo.saveFile(
            user.id, file.path!, "user request --> $title");
        return doc.id;
      }).toList();

      List<int> docIds = [];
      if (fileUploads != null) docIds = await Future.wait(fileUploads);

      final mId = await mRepo.send(msg);
      final text = msg.getMessageContent().title;

      if (docIds.isNotEmpty) {
        _slackFile(mId, text, files!, msg.threadTS);
      } else {
        _slackMessage(mId, text, msg.threadTS);
      }

      return mId;
    } catch (_) {
      throw Exception("errorOccurred");
    }
  }

  Future<void> _slackMessage(int mId, String title, String? threadTs) async {
    final user = userService.currentUser!;

    Logger().f("sending slack message, ${user.id}");

    final slackMessage = SlackMessage(
        messageId: mId,
        userId: user.id,
        fcmToken: fcm,
        channel: "request",
        title: title,
        threadTS: threadTs);

    sRepo.sendMessage(slackMessage).catchError((e) {
      Logger().e(e);

      return e;
    });
  }

  Future<void> _slackFile(
      int mId, String title, List<PlatformFile> files, String? threadTs) async {
    final user = userService.currentUser!;

    Logger().f("sending slack file, ${user.id}");

    final slackFile = SlackFile(
      messageID: mId,
      filePaths: files.map((e) => e.path!).toList(),
      fcm: fcm,
      userID: user.id,
      title: title,
      citizenship: user.country,
      channel: "request",
    );

    sRepo.sendFile(slackFile).catchError((e) {
      Logger().e(e);

      return e;
    });
  }
}
