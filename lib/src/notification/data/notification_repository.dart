import 'dart:convert';

import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/notification/domain/app_notification.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/shared/domain/retry_http_wrapper.dart';

class NotificationRepository {
  final RetryHttpClient _client;
  NotificationRepository(this._client);

  Future<void> setSuitable(int userId, int linkId, bool suitable) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'setNotificationSuitable',
    );

    final body = jsonEncode({
      "user_id": userId,
      "link_id": linkId,
      "suitable": suitable,
    });

    await _client.request(
      uri: uri,
      method: "PATCH",
      body: body,
    );
  }

  Future<void> setRead(int linkId, int userId) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'readNotification',
    );

    final body = jsonEncode({
      "user_id": userId,
      "link_id": linkId,
    });

    await _client.request(
      uri: uri,
      method: "PATCH",
      body: body,
    );
  }

  Future<List<AppNotification>?> fetchNotifications(int userId) async {
    final uri = Uri(
        scheme: 'https',
        host: 'diploma-mobile-backend-production.up.railway.app',
        path: 'fetchNotifications',
        queryParameters: {
          "user_id": "$userId",
        });

    final response = await _client.request(
      uri: uri,
      method: "GET",
    );

    final langService = getIt<LanguageService>();

    List<dynamic>? jsonList = jsonDecode(response.body);
    return jsonList
        ?.map((jsonItem) =>
            AppNotification.fromJson(jsonItem, langService.current.code))
        .toList();
  }
}
