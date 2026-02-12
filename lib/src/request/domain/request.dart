import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/shared/domain/message_content.dart';
import 'package:diplomaapp/src/shared/domain/user.dart';

class Message {
  int? id;
  final int? parentMsgId;
  final User sender;
  final User recipient;
  final Map<String, MessageContent> messageContent;
  final DateTime? date;
  final bool? read;
  List<int>? documentIDs;
  String? threadTS;

  Message(
      {this.id,
      this.parentMsgId,
      required this.messageContent,
      required this.sender,
      required this.recipient,
      this.read = false,
      this.date,
      this.threadTS,
      this.documentIDs});

  MessageContent getMessageContent() {
    final langCode = getIt<LanguageService>().current.code;
    MessageContent mContent = messageContent[langCode]!;

    if (mContent.title != "") {
      return mContent;
    } else {
      List<String> langCodes = ["si", "en", "bs"];
      for (var lCode in langCodes) {
        if (lCode == langCode) {
          continue;
        }
        if (messageContent[lCode]?.title != "") {
          return messageContent[lCode]!;
        }
      }
      return mContent;
    }
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    var documentIds = json['document_ids'] != null
        ? List<int>.from(json['document_ids'])
        : null;

    var translations = json["translations"];
    var messageContent = {
      "si": MessageContent.fromJson(translations["si"]),
      "en": MessageContent.fromJson(translations["en"]),
      "bs": MessageContent.fromJson(translations["bs"]),
    };

    return Message(
      id: json["id"] as int,
      messageContent: messageContent,
      sender: User.fromJson(json['sender']),
      recipient: User.fromJson(json['recipient']),
      threadTS: json["thread_ts"],
      date: DateTime.parse(json['date'] as String),
      documentIDs: documentIds,
      read: json['read'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    var mContent = {
      "si": messageContent["si"]?.toJson(),
      "en": messageContent["en"]?.toJson(),
      "bs": messageContent["bs"]?.toJson(),
    };

    return {
      "parent_msg_id": parentMsgId,
      "id": id,
      "read": read,
      "sender": sender.toJson(),
      "recipient": recipient.toJson(),
      "translations": mContent,
      "document_ids": documentIDs,
      "thread_ts": threadTS,
    };
  }
}
