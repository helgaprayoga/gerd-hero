import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton HTTP client untuk komunikasi dengan Flask backend.
///
/// Bearer token diambil otomatis dari session Supabase yang sedang aktif.
/// Gunakan [ApiException] untuk menangani error dari respons backend.
class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  String get _baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  String? get _token =>
      Supabase.instance.client.auth.currentSession?.accessToken;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
    );
    return _parse(response);
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _parse(response);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
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
