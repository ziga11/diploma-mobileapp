class MessageContent {
  final String title;
  final String text;

  MessageContent({required this.title, required this.text});

  factory MessageContent.fromJson(Map<String, dynamic> json) {
    return MessageContent(
      title: json['title'] as String,
      text: json['body'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "body": text,
    };
  }
}
