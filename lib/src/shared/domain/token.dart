class Token {
  final int? accId;
  final String? email;
  final String? token;
  final String? type;
  final DateTime? expriesAt;

  Token({
    this.accId,
    this.email,
    this.token,
    this.type,
    this.expriesAt,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accId: json["user_id"],
      token: json["raw_token"],
      type: json["type"],
      expriesAt: json["expires_at"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "account_id": accId,
      "email": email,
      "token": token,
      "type": type,
      "expires_at": expriesAt?.toUtc().toIso8601String(),
    };
  }
}
