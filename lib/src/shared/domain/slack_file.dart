class SlackFile {
  final int? messageID;
  final int? obligationID;
  final int userID;
  final String citizenship;
  final String fcm;
  final List<String> filePaths;
  final String title;
  final String? body;
  final String channel;
  final String? threadTS;

  SlackFile(
      {this.threadTS,
      this.messageID,
      this.obligationID,
      this.body = "",
      required this.citizenship,
      required this.userID,
      required this.fcm,
      required this.filePaths,
      required this.title,
      required this.channel});

  Map<String, dynamic> toJson() {
    return {
      "message_id": messageID,
      "obligation_id": obligationID,
      "user_id": userID,
      "drive_ids": filePaths,
      "channel": channel,
      "title": title,
      "body": body,
      "fcm_token": fcm,
      "thread_ts": threadTS
    };
  }
}
