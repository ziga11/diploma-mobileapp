import 'dart:convert';

import 'package:diplomaapp/src/employment/domain/job.dart';
import 'package:diplomaapp/src/shared/domain/retry_http_wrapper.dart';

class EmploymentRepository {
  final RetryHttpClient _client;
  EmploymentRepository(this._client);

  Future<Job?> employmentInfo(int userID) async {
    final uri = Uri(
        scheme: 'https',
        host: 'diploma-mobile-backend-production.up.railway.app',
        path: 'jobInfo',
        queryParameters: {
          "user_id": "$userID",
        });

    final response = await _client.request(
      uri: uri,
      method: "GET",
    );

    final data = jsonDecode(response.body);

    return Job.fromJson(data);
  }
}
