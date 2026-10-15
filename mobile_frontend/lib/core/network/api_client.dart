import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl =>
      (dotenv.env['API_BASE_URL'] ?? '').replaceFirst(RegExp(r'/$'), '');

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final response = await _client.get(
      _buildUri(path, queryParameters),
      headers: await _headers(),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.post(
      _buildUri(path),
      headers: {...await _headers(), 'Content-Type': 'application/json'},
      body: jsonEncode(body ?? const <String, dynamic>{}),
    );
    return _decode(response);
  }

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    if (_baseUrl.isEmpty) {
      throw const ApiException('API_BASE_URL belum dikonfigurasi.');
    }
    return Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: queryParameters);
  }

  Future<Map<String, String>> _headers() async {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      throw const ApiException(
        'Sesi login tidak tersedia. Silakan masuk kembali.',
        statusCode: 401,
      );
    }
    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  String? get _accessToken {
    try {
      return Supabase.instance.client.auth.currentSession?.accessToken;
    } on AssertionError {
      return null;
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(response.body);
      payload = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      payload = <String, dynamic>{};
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          payload['message'] ??
          payload['error'] ??
          'Permintaan ke server gagal.';
      throw ApiException(message.toString(), statusCode: response.statusCode);
    }
    return payload;
  }
}
