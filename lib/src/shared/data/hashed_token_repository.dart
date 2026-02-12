import 'dart:convert';

import 'package:diplomaapp/src/shared/domain/retry_http_wrapper.dart';
import 'package:diplomaapp/src/shared/domain/token.dart';
import 'package:logger/logger.dart';

class HashedTokenRepository {
  final RetryHttpClient _client;
  HashedTokenRepository(this._client);

  Future<void> pwResetToken(Token token) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'resetPwToken',
    );

    await _client.request(
      uri: uri,
      method: "POST",
      body: jsonEncode(token.toJson()),
    );
  }

  Future<bool> matchingToken(Token token) async {
    final uri = Uri(
        scheme: 'https',
        host: 'diploma-mobile-backend-production.up.railway.app',
        path: 'matchingHashedToken',
        queryParameters: {
          "account_id": "${token.accId}",
          "token": token.token,
          "type": token.type,
        });

    try {
      await _client.request(uri: uri, method: "GET");
      return true;
    } catch (e) {
      Logger().e("Failed to match token $e");

      return false;
    }
  }

  Future<void> deleteToken(Token token) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'deleteHashedTokens',
    );

    await _client.request(
      uri: uri,
      method: "DELETE",
      body: jsonEncode(token.toJson()),
    );
  }
}
