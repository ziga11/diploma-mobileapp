import 'package:file_picker/file_picker.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/document/data/document_repository.dart';
import 'package:diplomaapp/src/document/domain/document.dart';
import 'package:diplomaapp/src/obligation/data/obligation_repository.dart';
import 'package:diplomaapp/src/obligation/domain/obligation.dart';
import 'package:diplomaapp/src/obligation/domain/user_obligation.dart';
import 'package:diplomaapp/src/services/firebase_api.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/data/slack_repository.dart';
import 'package:diplomaapp/src/shared/data/user_repository.dart';
import 'package:diplomaapp/src/shared/domain/slack_file.dart';

class ProfileController {
  final userService = getIt<UserService>();
  late final user = getIt<UserService>().currentUser!;

  final dRepo = getIt<DocumentRepository>();
  final oRepo = getIt<ObligationRepository>();
  final uRepo = getIt<UserRepository>();
  final ddObligationId = 63;
  final langCode = getIt<LanguageService>().current.code;

  Future<void> assignEuEfta() async {
    uRepo.setLanguage(userService.currentAccount!.id!, langCode);

    await uRepo.setUserGroup(user.id, "Napoteni Delavec");
    String country = user.country == "Slovenia" ? "Slovenia" : "EuEfta";
    await oRepo.assignObligations(country, user.id, "EU_EFTA");
  }

  Future<void> assignTujina(
      List<PlatformFile>? files, Obligation? obligation) async {
    final fcm = getIt<FirebaseAPI>().fcmToken!;

    uRepo.setLanguage(userService.currentAccount!.id!, langCode);

    bool isException = ["North Macedonia", "Bosnia and Herzegovina", "Serbia"]
        .contains(user.country);

    await uRepo.setUserGroup(user.id, "Tujina");
    user.group = "Tujina";
    await oRepo.assignObligations(isException ? user.country : "Other", user.id,
        files != null ? "CONFIRM" : "NONE");

    if (files == null) return;

    List<String> uris = [];
    List<int> docIds = [];

    for (var file in files) {
      final doc = await dRepo.saveFile(user.id, file.path!, "DD Kartica");

      if (doc.id == -1) return;

      uris.add(doc.driveId);
      docIds.add(doc.id);
    }

    bool setUolDoc = await oRepo.setObligationStatus(ObligationRecord(
      definition: obligation!,
      userId: user.id,
      id: ddObligationId,
      docIds: docIds,
      status: "Pending",
    ));

    if (!setUolDoc) return;

    SlackFile slackFile = SlackFile(
      citizenship: user.country,
      fcm: fcm,
      userID: user.id,
      filePaths: files.map((e) => e.path!).toList(),
      obligationID: ddObligationId,
      title: "${user.firstName} ${user.lastName} (Delovno Dovoljenje)",
      channel: "obligation",
    );
    getIt<SlackRepository>().sendFile(slackFile);
  }

  Future<Obligation> workpermitObligation() async =>
      (await oRepo.fetchObligationById(ddObligationId))!;

  Future<Document> workpermitDocument(int docId) async {
    return (await dRepo.fetchDocById(docId))!;
  }
}
