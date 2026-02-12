import 'dart:convert';

import 'package:diplomaapp/src/shared/domain/retry_http_wrapper.dart';
import 'package:diplomaapp/src/shared/domain/token.dart';

class EncryptedTokenRepository {
  final RetryHttpClient _client;
  EncryptedTokenRepository(this._client);

  Future<void> saveToken(Token token) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'saveEncryptedToken',
    );

    await _client.request(
      uri: uri,
      method: "POST",
      body: jsonEncode(token.toJson()),
    );
  }

  Future<void> deleteToken(Token token) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'deleteEncryptedTokens',
    );

    await _client.request(
      uri: uri,
      method: "DELETE",
      body: jsonEncode(token.toJson()),
    );
  }
}
