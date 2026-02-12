import 'package:diplomaapp/src/obligation/domain/obligation.dart';

class ObligationRecord {
  final int id;
  final int userId;
  final String status;
  final Obligation definition;
  final String? reasoning;
  final DateTime? date;
  String? textValue;
  final List<int> docIds;

  ObligationRecord({
    required this.id,
    required this.userId,
    required this.definition,
    this.reasoning,
    this.date,
    this.status = "Incomplete",
    this.docIds = const [],
    this.textValue,
  });

  factory ObligationRecord.fromJson(Map<String, dynamic> json) {
    return ObligationRecord(
      id: json["id"],
      userId: json["user_id"],
      definition: Obligation.fromJson(json),
      textValue: json["text_value"],
      docIds: List<int>.from(json["uploaded_doc_ids"] ?? []),
      status: json["status"],
      reasoning: json["reasoning"],
      date: DateTime.parse(json["date"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "obligation_id": id,
      "user_id": userId,
      "status": status,
      "doc_ids": docIds,
      "text_value": textValue,
    };
  }

  ObligationRecord copyWith(
      {String? status,
      String? reasoning,
      DateTime? date,
      String? textValue,
      List<int>? docIds}) {
    return ObligationRecord(
      id: id,
      userId: userId,
      definition: definition,
      status: status ?? this.status,
      reasoning: reasoning ?? this.reasoning,
      date: date ?? this.date,
      textValue: textValue ?? this.textValue,
      docIds: docIds ?? this.docIds,
    );
  }
}
