import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

/// Singleton HTTP client untuk komunikasi dengan Flask backend.
///
/// Bearer token diambil otomatis dari session Supabase yang sedang aktif.
/// Gunakan [ApiException] untuk menangani error dari respons backend.
class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';

  String? get _token =>
      AuthService.instance.currentSession?.accessToken;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> get(String path) async {
    return _request(() => http.get(Uri.parse('$_baseUrl$path'), headers: _headers));
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _request(() => http.put(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    ));
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _request(() => http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    ));
  }

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() send,
  ) async {
    var response = await send();
    if (response.statusCode == 401 && _token != null) {
      try {
        await AuthService.instance.refreshSession();
        response = await send();
      } catch (_) {
        await AuthService.instance.signOut();
      }
    }
    return _parse(response);
  }

  Map<String, dynamic> _parse(http.Response response) {
    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const ApiException('Respons server tidak valid.', 500);
    }

    if (response.statusCode >= 400) {
      throw ApiException(
        decoded['message'] as String? ?? 'Terjadi kesalahan.',
        response.statusCode,
      );
    }

    return decoded;
  }
}

/// Exception yang dilempar saat backend mengembalikan status code >= 400.
class ApiException implements Exception {
  const ApiException(this.message, this.statusCode);

  final String message;
  final int statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
