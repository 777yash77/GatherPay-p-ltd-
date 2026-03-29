import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/app_models.dart';

class ApiService {
  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (configured.isNotEmpty) {
      return configured;
    }

    if (kIsWeb) {
      final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
      final scheme = host == 'localhost' || host == '127.0.0.1' ? 'http' : Uri.base.scheme;
      return '$scheme://$host:9191/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:9191/api';
      default:
        return 'http://localhost:9191/api';
    }
  }

  static Future<AuthSession> login(String email, String password) async {
    final response = await _send(
      () => http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers(),
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );

    return AuthSession.fromJson(_decodeBody(response));
  }

  static Future<AuthSession> register({
    required String name,
    required String email,
    required String mobileNumber,
    required String city,
    required String upiId,
    required String password,
  }) async {
    final response = await _send(
      () => http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'mobileNumber': mobileNumber,
          'city': city,
          'upiId': upiId,
          'password': password,
        }),
      ),
    );

    return AuthSession.fromJson(_decodeBody(response));
  }

  static Future<String> forgotPassword(String mobileNumber) async {
    final response = await _send(
      () => http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: _headers(),
        body: jsonEncode({'mobileNumber': mobileNumber}),
      ),
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }

    return response.body;
  }

  static Future<UserProfile> getProfile(String token) async {
    final response = await _send(
      () => http.get(
        Uri.parse('$baseUrl/profile'),
        headers: _headers(token: token),
      ),
    );
    return UserProfile.fromJson(_decodeBody(response));
  }

  static Future<UserProfile> updateProfile(String token, UserProfile profile) async {
    final response = await _send(
      () => http.put(
        Uri.parse('$baseUrl/profile'),
        headers: _headers(token: token),
        body: jsonEncode(profile.toUpdateJson()),
      ),
    );
    return UserProfile.fromJson(_decodeBody(response));
  }

  static Future<List<PoolModel>> fetchPools(String token) async {
    final response = await _send(
      () => http.get(
        Uri.parse('$baseUrl/pools'),
        headers: _headers(token: token),
      ),
    );
    final body = _decodeBody(response) as List<dynamic>;
    return body
        .cast<Map<String, dynamic>>()
        .map(PoolModel.fromJson)
        .toList();
  }

  static Future<PoolModel> createPool(String token, PoolModel pool) async {
    final response = await _send(
      () => http.post(
        Uri.parse('$baseUrl/pools'),
        headers: _headers(token: token),
        body: jsonEncode(pool.toRequestJson()),
      ),
    );
    return PoolModel.fromJson(_decodeBody(response));
  }

  static Future<PoolModel> updatePool(String token, PoolModel pool) async {
    final response = await _send(
      () => http.put(
        Uri.parse('$baseUrl/pools/${pool.id}'),
        headers: _headers(token: token),
        body: jsonEncode(pool.toRequestJson()),
      ),
    );
    return PoolModel.fromJson(_decodeBody(response));
  }

  static Future<void> deletePool(String token, String poolId) async {
    final response = await _send(
      () => http.delete(
        Uri.parse('$baseUrl/pools/$poolId'),
        headers: _headers(token: token),
      ),
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }
  }

  static Future<PoolModel> contribute({
    required String token,
    required String poolId,
    required int amount,
    required String upiId,
  }) async {
    final response = await _send(
      () => http.post(
        Uri.parse('$baseUrl/pools/$poolId/contributions'),
        headers: _headers(token: token),
        body: jsonEncode({
          'amount': amount,
          'upiId': upiId,
        }),
      ),
    );
    return PoolModel.fromJson(_decodeBody(response));
  }

  static Future<List<PoolChatMessage>> fetchPoolChat({
    required String token,
    required String poolId,
  }) async {
    final response = await _send(
      () => http.get(
        Uri.parse('$baseUrl/pools/$poolId/chat'),
        headers: _headers(token: token),
      ),
    );
    final body = _decodeBody(response) as List<dynamic>;
    return body
        .cast<Map<String, dynamic>>()
        .map(PoolChatMessage.fromJson)
        .toList();
  }

  static Future<PoolChatMessage> sendPoolChatMessage({
    required String token,
    required String poolId,
    required String message,
  }) async {
    final response = await _send(
      () => http.post(
        Uri.parse('$baseUrl/pools/$poolId/chat'),
        headers: _headers(token: token),
        body: jsonEncode({'message': message}),
      ),
    );
    return PoolChatMessage.fromJson(_decodeBody(response));
  }

  static Future<PoolModel> payoutPool({
    required String token,
    required String poolId,
    bool force = false,
  }) async {
    final response = await _send(
      () => http.post(
        Uri.parse('$baseUrl/pools/$poolId/payout'),
        headers: _headers(token: token),
        body: jsonEncode({'force': force}),
      ),
    );
    return PoolModel.fromJson(_decodeBody(response));
  }

  static Future<List<AppNotificationModel>> fetchNotifications(String token) async {
    final response = await _send(
      () => http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: _headers(token: token),
      ),
    );
    final body = _decodeBody(response) as List<dynamic>;
    return body
        .cast<Map<String, dynamic>>()
        .map(AppNotificationModel.fromJson)
        .toList();
  }

  static Future<List<MemberDirectoryEntry>> searchUsers({
    required String token,
    required String query,
  }) async {
    final response = await _send(
      () => http.get(
        Uri.parse('$baseUrl/users/search?q=${Uri.encodeQueryComponent(query)}'),
        headers: _headers(token: token),
      ),
    );
    final body = _decodeBody(response) as List<dynamic>;
    return body
        .cast<Map<String, dynamic>>()
        .map(MemberDirectoryEntry.fromUserJson)
        .toList();
  }

  static Future<AppNotificationModel> markNotificationRead({
    required String token,
    required String notificationId,
    required bool read,
  }) async {
    final response = await _send(
      () => http.patch(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: _headers(token: token),
        body: jsonEncode({'read': read}),
      ),
    );
    return AppNotificationModel.fromJson(_decodeBody(response));
  }

  static Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _decodeBody(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }
    if (response.body.isEmpty) {
      return {};
    }
    return jsonDecode(response.body);
  }

  static String _errorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message'] as String? ?? 'Request failed';
    } catch (_) {
      return response.body.isEmpty ? 'Request failed' : response.body;
    }
  }

  static Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(const Duration(seconds: 20));
    } on SocketException {
      throw Exception(
        'Cannot reach the backend. Start the server or set API_BASE_URL to your deployed backend URL.',
      );
    } on FormatException {
      throw Exception('Backend returned an unexpected response.');
    } on HttpException {
      throw Exception('Network error while talking to the backend.');
    } on http.ClientException {
      throw Exception(
        'Backend request failed. If you are using Flutter Web, restart the backend after the CORS update or set API_BASE_URL to the correct backend URL.',
      );
    }
  }
}
