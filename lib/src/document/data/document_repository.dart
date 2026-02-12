import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/document/domain/document.dart';
import 'package:diplomaapp/src/shared/domain/exceptions.dart';
import 'package:diplomaapp/src/shared/domain/retry_http_wrapper.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

final logger = Logger();

class DocumentRepository {
  final RetryHttpClient _client;
  DocumentRepository(this._client);

  Future<Uint8List?> fetchBytes(int documentId) async {
    final uri = Uri(
        scheme: 'https',
        host: 'diploma-mobile-backend-production.up.railway.app',
        path: 'fetchFile',
        queryParameters: {
          "id": "$documentId",
        });

    final respone = await _client.request(
      uri: uri,
      method: "GET",
    );

    return respone.bodyBytes;
  }

  Future<Document?> fetchDocById(int? docId) async {
    if (docId == null) return null;
    final uri = Uri(
        scheme: 'https',
        host: 'diploma-mobile-backend-production.up.railway.app',
        path: 'fetchDocById',
        queryParameters: {
          "id": "$docId",
        });

    final response = await _client.request(
      uri: uri,
      method: "GET",
    );

    var json = jsonDecode(response.body);
    return Document.fromJson(json);
  }

  Future<List<Document>> fetchDocuments(int userId) async {
    final uri = Uri(
        scheme: 'https',
        host: 'diploma-mobile-backend-production.up.railway.app',
        path: 'fetchDocs',
        queryParameters: {
          "user_id": "$userId",
        });

    final response = await _client.request(
      uri: uri,
      method: "GET",
    );

    try {
      var json = jsonDecode(response.body) as List;

      return json.map((entry) => Document.fromJson(entry)).toList();
    } catch (e) {
      Logger().e(e);
      return [];
    }
  }

  Future<File> downloadFile(Document document) async {
    String filename = path.basename(document.driveId);
    try {
      var tempDir = await getTemporaryDirectory();
      String fullPath = "${tempDir.path}/$filename";

      return File(fullPath).writeAsBytes((await fetchBytes(document.id))!);
    } catch (e) {
      logger.i(e);

      throw Exception("Error downloading file");
    }
  }

  Future<void> deleteFile(int docId) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'deleteDocument',
    );

    await _client.request(
      uri: uri,
      method: "DELETE",
      body: jsonEncode({
        "id": docId,
      }),
    );
  }

  Future<Document> saveFile(
    int userID,
    String filePath,
    String type,
  ) async {
    final uri = Uri(
      scheme: 'https',
      host: 'diploma-mobile-backend-production.up.railway.app',
      path: 'saveFile',
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
      ..fields['user_id'] = userID.toString()
      ..fields['title'] = path.basename(filePath)
      ..fields['type'] = type
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          filename: path.basename(filePath),
        ),
      );

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

      final data = jsonDecode(body);

      return Document.fromJson(data);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException(original: e);
    } on TimeoutException catch (e) {
      throw NetworkException(original: e);
    }
  }
}
