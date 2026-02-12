import 'dart:convert';

import 'package:diplomaapp/src/shared/domain/account.dart';
import 'package:diplomaapp/src/shared/domain/retry_http_wrapper.dart';
import 'package:diplomaapp/src/shared/domain/user.dart';

class UserRepository {
  final RetryHttpClient _client;
  UserRepository(this._client);

  Future updateUser(User user) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'updateUser',
    );

    await _client.request(
      uri: uri,
      method: "PATCH",
      body: jsonEncode(user.toJson()),
    );
  }

  Future<List<User>> fetchUsers(String? search) async {
    if (search!.isEmpty) return [];
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'fetchUsers',
      queryParameters: {
        'serach': search,
      },
    );

    final response = await _client.request(
      uri: uri,
      method: "GET",
    );

    List<dynamic> dataList = jsonDecode(response.body);
    List<User> users = dataList.map((user) => User.fromJson(user)).toList();

    return users;
  }

  Future<void> setLanguage(int accId, String langCode) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'setLangCode',
    );

    await _client.request(
      uri: uri,
      method: "PATCH",
      body: jsonEncode({
        "account_id": accId,
        "lang_code": langCode,
      }),
    );
  }

  Future<User?> getUserById(int userID) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'userByID',
      queryParameters: {
        'user_id': '$userID',
      },
    );

    final response = await _client.request(
      uri: uri,
      method: "GET",
    );

    final data = jsonDecode(response.body);
    return User.fromJson(data);
  }

  Future<Account?> accountById(int accountId) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'accountById',
      queryParameters: {
        'account_id': "$accountId",
      },
    );

    final response = await _client.request(
      uri: uri,
      method: "GET",
    );

    final data = jsonDecode(response.body);
    return Account.fromJson(data);
  }

  Future<void> setUserGroup(int userId, String groupname) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'updateUserGroup',
    );

    var body = jsonEncode({
      "user_id": userId,
      "name": groupname,
    });

    await _client.request(
      uri: uri,
      method: "PATCH",
      body: body,
    );
  }
}
