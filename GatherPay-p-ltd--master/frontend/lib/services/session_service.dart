import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';

class SessionService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  static Future<void> saveSession(AuthSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, session.token);
    final userJson = session.user.toUpdateJson();
    userJson['id'] = session.user.id;
    userJson['createdAt'] = session.user.createdAt.toIso8601String();
    userJson['profileCompleted'] = session.user.profileCompleted;
    await preferences.setString(
      _userKey,
      jsonEncode(userJson),
    );
  }

  static Future<AuthSession?> loadSession() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_tokenKey);
    final userRaw = preferences.getString(_userKey);

    if (token == null || userRaw == null) {
      return null;
    }

    final user = UserProfile.fromJson(
      jsonDecode(userRaw) as Map<String, dynamic>,
    );
    return AuthSession(token: token, user: user);
  }

  static Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
    await preferences.remove(_userKey);
  }
}
