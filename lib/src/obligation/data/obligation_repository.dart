import 'dart:convert';

import 'package:diplomaapp/src/obligation/domain/obligation.dart';
import 'package:diplomaapp/src/obligation/domain/user_obligation.dart';
import 'package:diplomaapp/src/shared/domain/exceptions.dart';
import 'package:diplomaapp/src/shared/domain/retry_http_wrapper.dart';

class ObligationRepository {
  final RetryHttpClient _client;
  ObligationRepository(this._client);

  Future<List<ObligationRecord>> fetchObligations(int userId) async {
    final uri = Uri(
        scheme: 'https',
        host: 'diploma-mobile-backend-production.up.railway.app',
        path: 'userObligations',
        queryParameters: {
          "user_id": "$userId",
        });

    final response = await _client.request(
      uri: uri,
      method: "GET",
    );

    List<dynamic> data = jsonDecode(response.body);

    return data.map((item) => ObligationRecord.fromJson(item)).toList();
  }

  Future<bool> setObligationStatus(ObligationRecord userObligation) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'setUserObligation',
    );

    try {
      await _client.request(
        uri: uri,
        method: "PATCH",
        body: jsonEncode(userObligation.toJson()),
      );
      return true;
    } on ApiException catch (_) {
      return false;
    }
  }

  Future<void> assignObligations(
      String? country, int userId, String workpermitStatus) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'assignObligations',
    );

    final body = jsonEncode({
      'country': country,
      'user_id': userId,
      'workpermit_status': workpermitStatus,
    });

    await _client.request(
      uri: uri,
      method: "POST",
      body: body,
    );
  }

  Future<Obligation?> fetchObligationById(int id) async {
    final uri = Uri(
        scheme: 'https',
        host: 'diploma-mobile-backend-production.up.railway.app',
        path: 'fetchObligationById',
        queryParameters: {"id": "$id"});

    final response = await _client.request(
      uri: uri,
      method: "GET",
    );

    final data = jsonDecode(response.body);
    return Obligation.fromJson(data);
  }
}
