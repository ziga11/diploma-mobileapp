class Document {
  final int id;
  final int userId;
  final DateTime? date;
  final String driveId;
  final String title;
  final String type;
  final String? mimeType;

  Document(
      {required this.id,
      required this.userId,
      this.date,
      required this.driveId,
      required this.title,
      required this.mimeType,
      required this.type});

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json["id"],
      date: DateTime.parse(json['date'] as String),
      userId: json["user_id"],
      driveId: json["drive_id"],
      title: json["title"],
      type: json["type"],
      mimeType: json["mimetype"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "drive_id": driveId,
      "title": title,
      "type": type,
      "date": date.toString()
    };
  }

  bool isPdf() => mimeType == "application/pdf";
  bool isImg() => mimeType?.contains("image") ?? false;
  bool isDocx() => mimeType?.endsWith("wordprocessingml.document") ?? false;

  String get fileIcon {
    switch (mimeType) {
      case 'application/pdf':
        return 'assets/pdf_icon.png';
      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
      case 'application/vnd.ms-excel':
        return 'assets/excel_icon.png';
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return 'assets/word.png';
      case 'image/jpeg':
      case 'image/png':
        return 'assets/image_icon.png';
      default:
        return 'assets/attachment_icon.png';
    }
  }
}
