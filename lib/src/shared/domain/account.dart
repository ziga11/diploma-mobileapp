import 'package:diplomaapp/src/shared/domain/language.dart';

class Account {
  int? id;
  String email;
  int? userId;
  Language? language;
  DateTime? createdAt;

  Account({
    this.id,
    this.userId,
    this.createdAt,
    required this.email,
    required this.language,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      email: json['email'] as String,
      language: Language.from(json["lang_code"] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_id': userId,
      'lang_code': language.toString(),
    };
  }
}
