import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/model/user_model.dart';

class SessionManager {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  static Future<void> saveSession({required String token, required UserModel user}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  static Future<(String?, UserModel?)> loadSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(_keyToken);
    final String? userJson = prefs.getString(_keyUser);
    UserModel? user;
    if (userJson != null) {
      try {
        user = UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {
        user = null;
      }
    }
    return (token, user);
  }

  static Future<void> clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }
}




