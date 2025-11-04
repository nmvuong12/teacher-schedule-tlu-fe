import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  static Future<void> saveSession({required String token, required Map<String, dynamic> userJson}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUser, jsonEncode(userJson));
  }

  // ✅ HÀM MỚI (Từ file "cũ" của bạn)
  // Hàm này sẽ được ApiService gọi để lấy token
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<(String?, Map<String, dynamic>?)> loadSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(_keyToken);
    final String? userJson = prefs.getString(_keyUser);
    Map<String, dynamic>? user;
    if (userJson != null) {
      try {
        user = jsonDecode(userJson) as Map<String, dynamic>;
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

  // ✅ HÀM LOGOUT (Từ file bạn tải lên)
  static Future<void> logout() async {
    await clearSession();
    // Có thể thêm logic khác như gọi API logout nếu cần
  }
}