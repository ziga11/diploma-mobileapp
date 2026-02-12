import 'package:diplomaapp/src/shared/domain/message_content.dart';

class Obligation {
  final int id;
  final bool isUploadble;
  final bool hasTextField;
  final Map<String, MessageContent> translations;
  final int? exampleDocId;
  final String? googleFileId;

  Obligation(
      {required this.translations,
      required this.id,
      required this.isUploadble,
      required this.hasTextField,
      this.exampleDocId,
      this.googleFileId});

  factory Obligation.fromJson(Map<String, dynamic> json) {
    var translations = json["translations"];
    var obligationContent = {
      "si": MessageContent.fromJson(translations["si"]),
      "en": MessageContent.fromJson(translations["en"]),
      "bs": MessageContent.fromJson(translations["bs"]),
    };

    return Obligation(
      id: json["id"],
      translations: obligationContent,
      isUploadble: json["is_uploadable"],
      exampleDocId: json["example_doc_id"],
      googleFileId: json["google_file_id"],
      hasTextField: json["has_text_field"],
    );
  }
}
