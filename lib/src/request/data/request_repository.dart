import 'dart:convert';

import 'package:diplomaapp/src/request/domain/request.dart';
import 'package:diplomaapp/src/shared/domain/retry_http_wrapper.dart';

class MessageRepository {
  final RetryHttpClient _client;
  MessageRepository(this._client);

  Future<List<Message>?> fetchMessages(int userId, {int? mId}) async {
    final queryParams = <String, String>{
      'user_id': "$userId",
      "message_id": "$mId",
    };

    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'fetchMessages',
      queryParameters: queryParams,
    );

    final response = await _client.request(
      uri: uri,
      method: "GET",
    );

    List<dynamic>? jsonList = jsonDecode(response.body);
    return jsonList?.map((jsonItem) => Message.fromJson(jsonItem)).toList();
  }

  Future<List<Message>> fetchThread(int msgId, int userId) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'fetchMsgThread',
      queryParameters: {"message_id": "$msgId", "user_id": "$userId"},
    );

    final response = await _client.request(
      uri: uri,
      method: "GET",
    );

    List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((jsonItem) => Message.fromJson(jsonItem)).toList();
  }

  Future<int> send(Message msg) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'sendMessage',
    );

    final response = await _client.request(
      uri: uri,
      method: "POST",
      body: jsonEncode(msg.toJson()),
    );

    Map<String, dynamic> map = jsonDecode(response.body);
    return map["message_id"];
  }

  Future<void> setRead(int msgId, int userId) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'setReadMessage',
    );

    final body = jsonEncode({
      "message_id": msgId,
      "user_id": userId,
      "read": true,
    });

    await _client.request(
      uri: uri,
      method: "PATCH",
      body: body,
    );
  }
}
