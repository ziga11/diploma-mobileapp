class Job {
  final int? id;
  final int? companyId;
  final int? userId;
  final String? companyName;
  final String title;
  final String? status;
  final DateTime? startContract;
  final DateTime? endContract;

  Job({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.userId,
    required this.status,
    required this.title,
    required this.startContract,
    required this.endContract,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json["job_id"],
      userId: json["user_id"],
      companyId: json["company_id"],
      companyName: json["company_name"],
      title: json["job_title"],
      status: json.containsKey("status") ? json["status"] : null,
      startContract: json.containsKey('start_date')
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endContract: json.containsKey('end_date')
          ? DateTime.parse(json['end_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "user_id": userId,
      "job_id": id,
      "job_title": title,
      "company_id": companyId,
      "company_name": companyName,
    };
  }
}
