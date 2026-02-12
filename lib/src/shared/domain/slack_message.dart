class SlackMessage {
  final int? messageId;
  final int? obligationId;
  final int userId;
  final String fcmToken;
  final String channel;
  final String title;
  final String body;
  final String? threadTS;

  SlackMessage({
    this.messageId,
    this.obligationId,
    required this.userId,
    required this.channel,
    required this.fcmToken,
    this.threadTS,
    required this.title,
    this.body = "",
  });

  factory SlackMessage.fromJson(Map<String, dynamic> json) {
    return SlackMessage(
      messageId: json["message_id"],
      obligationId: json["obligation_id"],
      userId: json["user_id"],
      channel: json["channel"],
      fcmToken: json["fcm_token"],
      title: json["title"],
      body: json["body"],
      threadTS: json["thread_ts"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message_id": messageId,
      "user_id": userId,
      "obligation_id": obligationId,
      "title": title,
      "body": body,
      "channel": channel,
      "fcm_token": fcmToken,
      "thread_ts": threadTS,
    };
  }
}
