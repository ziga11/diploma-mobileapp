import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/shared/domain/exceptions.dart';
import 'package:diplomaapp/src/shared/domain/retry_http_wrapper.dart';
import 'package:diplomaapp/src/shared/domain/slack_message.dart';
import 'package:diplomaapp/src/shared/domain/slack_file.dart';

class SlackRepository {
  final RetryHttpClient _client;
  SlackRepository(this._client);

  Future<String?> sendMessage(SlackMessage slackMsg) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'sendSlackMsg',
    );

    final response = await _client.request(
      uri: uri,
      method: "POST",
      body: jsonEncode(slackMsg.toJson()),
    );

    Map<String, dynamic> map = jsonDecode(response.body);
    return map["thread_ts"];
  }

  Future<String> sendFile(SlackFile slackFile) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'sendSlackFile',
    );

    final secureToken =
        await getIt<FlutterSecureStorage>().read(key: "secure_token");
    final accId = await getIt<FlutterSecureStorage>().read(key: "acc_id");

    if (secureToken == null || accId == null) {
      throw ApiException(
        statusCode: 400,
        message: 'AccId or secure token is null',
      );
    }

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $secureToken',
        'X-Account-ID': accId,
      })
      ..fields['user_id'] = "${slackFile.userID}"
      ..fields['obligation_id'] = "${slackFile.obligationID}"
      ..fields['message_id'] = "${slackFile.messageID}"
      ..fields['channel'] = slackFile.channel
      ..fields['fcm'] = slackFile.fcm
      ..fields['title'] = slackFile.title
      ..fields['citizenship'] = slackFile.citizenship;

    for (var path in slackFile.filePaths) {
      request.files.add(await http.MultipartFile.fromPath('files', path));
    }

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to save file',
          responseBody: body,
        );
      }

      final threadTs = jsonDecode(body);

      return threadTs as String;
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException(original: e);
    } on TimeoutException catch (e) {
      throw NetworkException(original: e);
    }
  }
}
