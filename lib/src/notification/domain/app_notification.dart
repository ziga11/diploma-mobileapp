import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/services/language_service.dart';

class AppNotification {
  final int linkId;
  final String type;
  final DateTime date;
  bool read;
  bool? suitable;
  final String title;
  final String body;
  final String? threadTs;

  AppNotification({
    required this.linkId,
    required this.type,
    required this.date,
    required this.read,
    required this.suitable,
    required this.title,
    required this.body,
    this.threadTs,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json, String langCode) {
    final translation =
        json['translations'][langCode] ?? json['translations']['en'] ?? {};

    return AppNotification(
      linkId: int.tryParse(json['link_id'] ?? '0') ?? 0,
      type: json['type'],
      date: DateTime.parse(json['date']),
      read: json['read'] ?? false,
      suitable: json['suitable'],
      title: translation['title'],
      body: translation['body'] ?? '',
      threadTs: json.containsKey("thread_ts") ? json["thread_ts"] : "",
    );
  }

  factory AppNotification.fromFcm(RemoteMessage rm) {
    final data = rm.data;

    return AppNotification(
      linkId: int.tryParse(data['link_id'] ?? '0') ?? 0,
      type: data['type'],
      date: DateTime.now(),
      read: false,
      suitable: null,
      title: rm.notification?.title ?? '',
      body: rm.notification?.body ?? '',
      threadTs: data['thread_ts'],
    );
  }

  Map<String, dynamic> toJson() {
    final langService = getIt<LanguageService>();

    return {
      "linkId": linkId,
      "type": type,
      "date": date.toIso8601String(),
      "read": read,
      "suitable": suitable,
      'translations': {
        langService.current.code: {
          'title': title,
          'body': body,
        }
      },
      "threadTs": threadTs,
    };
  }
}
