import 'package:diplomaapp/src/services/language_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/document/data/document_repository.dart';
import 'package:diplomaapp/src/obligation/data/obligation_repository.dart';
import 'package:diplomaapp/src/obligation/domain/user_obligation.dart';
import 'package:diplomaapp/src/services/firebase_api.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/data/slack_repository.dart';
import 'package:diplomaapp/src/shared/domain/slack_file.dart';
import 'package:diplomaapp/src/shared/domain/slack_message.dart';

class ObligationController extends ChangeNotifier {
  final ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  final dRepo = getIt<DocumentRepository>();
  final oRepo = getIt<ObligationRepository>();
  final sRepo = getIt<SlackRepository>();

  final user = getIt<UserService>().currentUser!;

  Future<void> startDownload({
    required String googleFileId,
    required String fileName,
    required BuildContext context,
  }) async {
    final translations = getIt<LanguageService>().translations.value;
    final messenger = ScaffoldMessenger.of(context);

    downloadProgress.value = 0.0;

    try {
      await FileDownloader.downloadFile(
        url: "https://drive.google.com/uc?export=download&id=$googleFileId",
        name: fileName,
        onProgress: (name, progress) {
          downloadProgress.value = progress;
        },
        onDownloadCompleted: (path) {
          downloadProgress.value = 1.0;
          messenger.hideCurrentSnackBar();

          String shortPath = path;
          if (path.contains('0/')) {
            shortPath = path.split('0/').last;
          }

          final String displayPath = Uri.decodeFull(shortPath);

          messenger.showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 8),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translations["downloadCompleted"]!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${translations["file"] ?? "File"}: $displayPath',
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        onDownloadError: (error) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text('${translations["errorOccurred"]}: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        },
      );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('${translations["errorOccurred"]}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<int>> uploadDocuments({
    required ValueNotifier<ObligationRecord> obNotifier,
    required String title,
    required List<PlatformFile> files,
  }) async {
    obNotifier.value = obNotifier.value.copyWith(status: 'Pending');
    final user = getIt<UserService>().currentUser!;

    const contractObligation = 33;

    final docIds = await Future.wait(files.map((file) async {
      return (await dRepo.saveFile(
              user.id,
              file.path!,
              obNotifier.value.id == contractObligation
                  ? "contract"
                  : file.name))
          .id;
    }));

    obNotifier.value = obNotifier.value.copyWith(docIds: docIds);

    final setUolDoc = await oRepo.setObligationStatus(obNotifier.value);
    if (!setUolDoc) return [];

    final fcm = getIt<FirebaseAPI>().fcmToken!;

    SlackFile slackFile = SlackFile(
      citizenship: user.country,
      fcm: fcm,
      userID: user.id,
      filePaths: files.map((e) => e.path!).toList(),
      obligationID: obNotifier.value.id,
      title: "${user.firstName} ${user.lastName} ($title)",
      channel: "obligation",
    );
    await sRepo.sendFile(slackFile);

    return docIds;
  }

  Future<void> deleteDocuments(
      {required ValueNotifier<ObligationRecord> on}) async {
    on.value = on.value.copyWith(
      status: 'Incomplete',
      docIds: [],
    );

    await oRepo.setObligationStatus(on.value);

    for (var docId in on.value.docIds) {
      dRepo.deleteFile(docId);
    }
  }

  Color getTileColor(String status) {
    switch (status) {
      case "Completed":
        return ColorTheme.green;
      case "Pending":
        return ColorTheme.orange;
      case "Incomplete":
      default:
        return ColorTheme.red;
    }
  }

  Future<void> setTextValue({
    required String textValue,
    required String title,
    required ValueNotifier<ObligationRecord> on,
  }) async {
    final fcm = getIt<FirebaseAPI>().fcmToken!;

    on.value = on.value.copyWith(
      status: "Pending",
      textValue: textValue,
    );

    final setUolDoc = await oRepo.setObligationStatus(on.value);
    if (!setUolDoc) return;

    sRepo.sendMessage(
      SlackMessage(
        userId: on.value.userId,
        obligationId: on.value.id,
        fcmToken: fcm,
        title: title,
        body: textValue,
        channel: "obligation",
      ),
    );
  }
}
