import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:path_finder/models/path_task.dart';
import 'package:path_finder/models/task_result.dart';

class ApiException implements Exception {
  const new(this.message, {this.statusCode});

  final String message;

  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  new({http.Client? client, this.timeout = const Duration(seconds: 15)})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  Future<List<PathTask>> fetchTasks(Uri url) async {
    final body = await _send(
      () => _client.get(url, headers: {'Accept': 'application/json'}),
    );

    final data = body['data'];
    if (data is! List) {
      throw const ApiException('Invalid response: "data" is not a list');
    }
    try {
      return [
        for (final item in data)
          if (item is Map<String, dynamic>)
            PathTask.fromJson(item)
          else
            throw const FormatException('task is not a JSON object'),
      ];
    } on FormatException catch (e) {
      throw ApiException('Invalid task data: ${e.message}');
    }
  }

  Future<void> submitResults(Uri url, List<TaskResult> results) async {
    await _send(
      () => _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode([for (final result in results) result.toJson()]),
      ),
    );
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    final http.Response response;
    try {
      response = await request().timeout(timeout);
    } on TimeoutException {
      throw const ApiException('The server did not respond in time');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    }

    final status = response.statusCode;
    final isHttpSuccess = status >= 200 && status < 300;

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw ApiException(
        isHttpSuccess
            ? 'Invalid response: body is not valid JSON'
            : _fallbackMessage(status),
        statusCode: status,
      );
    }

    if (decoded is! Map<String, dynamic> || decoded['error'] is! bool) {
      throw ApiException(
        isHttpSuccess
            ? 'Invalid response: unexpected format'
            : _fallbackMessage(status),
        statusCode: status,
      );
    }

    if (isHttpSuccess && decoded['error'] == false) return decoded;

    final message = decoded['message'];
    throw ApiException(
      message is String && message.isNotEmpty
          ? message
          : _fallbackMessage(status),
      statusCode: status,
    );
  }

  static String _fallbackMessage(int status) => switch (status) {
    429 => 'Too many requests. Please wait and try again.',
    >= 500 => 'Server error (HTTP $status)',
    >= 200 && < 300 => 'The server reported an error',
    _ => 'Request failed (HTTP $status)',
  };
}
