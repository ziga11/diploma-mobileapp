import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/shared/domain/exceptions.dart';

class RetryHttpClient {
  final http.Client _client;
  final int maxRetries;
  final Duration retryDelay;

  RetryHttpClient({
    http.Client? client,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  }) : _client = client ?? http.Client();

  /*diploma-mobile-backend-production.up.railway.app*/

  Future<http.Response> request({
    required Uri uri,
    String method = 'GET',
    Map<String, String>? headers,
    Object? body,
    Set<int>? retryStatusCodes,
  }) async {
    retryStatusCodes ??= {502};
    headers ??= {'Content-Type': 'application/json; charset=UTF-8'};
    int attempt = 0;

    final storage = getIt<FlutterSecureStorage>();

    final accId = await storage.read(key: "acc_id");
    if (accId != null) {
      headers['X-Account-ID'] = accId;
    }

    final token = await storage.read(key: 'secure_token');
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    while (true) {
      try {
        late http.Response response;

        switch (method.toUpperCase()) {
          case 'GET':
            response = await _client.get(uri, headers: headers);
            break;
          case 'POST':
            response = await _client.post(uri, headers: headers, body: body);
            break;
          case 'PATCH':
            response = await _client.patch(uri, headers: headers, body: body);
          case 'PUT':
            response = await _client.put(uri, headers: headers, body: body);
            break;
          case 'DELETE':
            response = await _client.delete(uri, headers: headers, body: body);
            break;
          default:
            throw ArgumentError('Unsupported HTTP method: $method');
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }

        final apiException = ApiException(
          statusCode: response.statusCode,
          message: 'HTTP ${response.statusCode} Error',
          responseBody: response.body,
        );

        attempt++;
        if (retryStatusCodes.contains(response.statusCode) &&
            attempt <= maxRetries) {
          await Future.delayed(retryDelay);
          continue;
        }

        throw apiException;
      } on SocketException catch (e) {
        throw NetworkException(original: e);
      } on TimeoutException catch (e) {
        throw NetworkException(original: e);
      } on ApiException {
        rethrow;
      } catch (e) {
        throw UnknownException(original: e);
      }
    }
  }
}
