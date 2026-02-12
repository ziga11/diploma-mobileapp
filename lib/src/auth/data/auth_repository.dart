import 'dart:convert';

import 'package:diplomaapp/src/auth/domain/login_response.dart';
import 'package:diplomaapp/src/shared/domain/account.dart';
import 'package:diplomaapp/src/shared/domain/retry_http_wrapper.dart';
import 'package:diplomaapp/src/shared/domain/user.dart';
import 'package:logger/logger.dart';

class AuthRepository {
  final RetryHttpClient _client;
  AuthRepository(this._client);

  Future<Map<String, dynamic>> setPW(
      {required String pw, String? token, int? accId}) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'setPW',
    );
    final body = jsonEncode({
      "account_id": accId,
      "pw": pw,
      "raw_token": token,
    });

    final response = await _client.request(
      uri: uri,
      method: "PATCH",
      body: body,
    );

    final data = jsonDecode(response.body);
    return data;
  }

  Future<void> resetPW(String email, String pw, String token) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'resetPW',
    );
    final body = jsonEncode({"email": email, "pw": pw, "token": token});

    await _client.request(
      uri: uri,
      method: "POST",
      body: body,
    );
  }

  Future<LoginResponse> attemptLogin(String email, String pw) async {
    final uri = Uri(
        scheme: 'https',
        host: 'diploma-mobile-backend-production.up.railway.app',
        path: 'login');

    try {
      final response = await _client.request(
        uri: uri,
        method: "POST",
        body: jsonEncode({
          "email": email,
          "pw": pw,
        }),
      );

      final data = jsonDecode(response.body);

      final User user = User.fromJson(data["user"]);
      final Account account = Account.fromJson(data["account"]);
      final String secureToken = data["secure_token"];
      final String repeatToken = data["repeat_token"];

      return LoginResponse(
          user: user,
          account: account,
          successful: true,
          secureToken: secureToken,
          repeatToken: repeatToken);
    } catch (e) {
      Logger().e("Login error: $e");
      return LoginResponse(
        successful: false,
        reasoning: e.toString(),
      );
    }
  }
}
