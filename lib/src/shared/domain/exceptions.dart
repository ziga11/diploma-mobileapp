class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? responseBody;

  ApiException({
    required this.statusCode,
    required this.message,
    this.responseBody,
  });

  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;

  @override
  String toString() {
    return 'ApiException('
        'statusCode: $statusCode, '
        'message: $message, '
        'responseBody: $responseBody'
        ')';
  }
}

class NetworkException implements Exception {
  final Object original;

  NetworkException({required this.original});

  @override
  String toString() => 'NetworkException($original)';
}

class UnknownException implements Exception {
  final Object original;

  UnknownException({required this.original});

  @override
  String toString() => 'UnknownException($original)';
}
