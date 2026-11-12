import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthApi {
  AuthApi({required this.baseUrl, http.Client? client})
    : _http = client ?? http.Client();

  final String baseUrl;
  final http.Client _http;
  static const _timeout = Duration(seconds: 15);

  Future<String> login(String email, String password) =>
      _authenticate('login', email, password);

  Future<String> register(String email, String password) =>
      _authenticate('register', email, password);

  Future<void> logout(String token) async {
    await _http
        .post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {'authorization': 'Bearer $token'},
        )
        .timeout(_timeout);
  }

  Future<String> _authenticate(
    String path,
    String email,
    String password,
  ) async {
    final response = await _http
        .post(
          Uri.parse('$baseUrl/auth/$path'),
          headers: {'content-type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(_timeout);

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = {};
    }
    if (response.statusCode != 200) {
      throw AuthException(body['error'] as String? ?? 'Request failed');
    }
    return body['token'] as String;
  }
}
