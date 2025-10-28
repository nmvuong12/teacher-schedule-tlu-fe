import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:typed_data'; // Import cần thiết cho utf8.encode
import '../../data/model/user_model.dart';
import 'session_manager.dart';

class NetworkService {

  // ✅ Tối ưu hóa baseUrl: Sử dụng 127.0.0.1 làm host tiêu chuẩn cho Web
  static String get baseUrl {
    if (kIsWeb) {
      // Dùng 127.0.0.1 cho Web/Desktop để tránh lỗi phân giải DNS của trình duyệt
      return 'http://127.0.0.1:8080/api';
    } else if (Platform.isAndroid) {
      // Dùng 10.0.2.2 cho Android Emulator
      return 'http://10.0.2.2:8080/api';
    } else {
      // Dùng 127.0.0.1 cho Desktop (Linux/Windows/Mac)
      return 'http://127.0.0.1:8080/api';
    }
  }

  // ✅ Login API - Gọi endpoint auth/login của backend (hỗ trợ BCrypt password)
  static Future<LoginResponse> login(String username, String password) async {
    try {
      // Gọi API login đúng của backend
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login?username=$username&password=$password'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final user = UserModel.fromJson(userData);
        final String token = base64Encode(
          Uint8List.fromList(
            utf8.encode('${user.username}:${user.role}:${DateTime.now().millisecondsSinceEpoch}')
          )
        );
        await SessionManager.saveSession(token: token, user: user);
        
        return LoginResponse(
          success: true,
          message: 'Đăng nhập thành công',
          user: user,
          token: token,
        );
      } else {
        // Xử lý lỗi từ backend
        try {
          final error = json.decode(response.body);
          return LoginResponse(
            success: false,
            message: error['error'] ?? 'Tài khoản hoặc mật khẩu không chính xác',
          );
        } catch (e) {
          return LoginResponse(
            success: false,
            message: 'Tài khoản hoặc mật khẩu không chính xác',
          );
        }
      }
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'Không thể kết nối đến server. Vui lòng kiểm tra:\n1. Server API có đang chạy không\n2. Kết nối mạng\n3. Firewall settings',
      );
    }
  }

  // Get user profile
  static Future<UserModel?> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get all users (Giữ nguyên)
  static Future<List<UserModel>> getAllUsers(String token) async {
    try {
      final response = await http.get(
        // Sử dụng baseUrl đã tối ưu
        Uri.parse('$baseUrl/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.map((user) => UserModel.fromJson(user)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ----------------------------------------------------
  // ✅ PHƯƠNG THỨC FORGOT PASSWORD
  // ----------------------------------------------------
  static Future<LoginResponse> forgotPassword(String email) async {
    try {
      // ✅ Sử dụng baseUrl đã tối ưu
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      ).timeout(const Duration(seconds: 30)); // Tăng timeout vì gửi email mất thời gian

      final data = json.decode(response.body);

      // Mã 2xx
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return LoginResponse(
          success: true,
          message: data['message'] ?? 'Link khôi phục mật khẩu đã được gửi.',
        );
      } else {
        // Mã 4xx, 5xx (Lỗi từ Server)
        return LoginResponse(
          success: false,
          message: data['message'] ?? 'Email không tồn tại hoặc yêu cầu thất bại.',
        );
      }
    } catch (e) {
      // Lỗi kết nối mạng (Network failure)
      return LoginResponse(
        success: false,
        message: 'Không thể kết nối đến server.',
      );
    }
  }

  // ----------------------------------------------------
  // ✅ PHƯƠNG THỨC RESET PASSWORD
  // ----------------------------------------------------
  static Future<LoginResponse> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password?token=$token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'newPassword': newPassword}),
      );

      final data = json.decode(response.body);

      // Mã 2xx
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return LoginResponse(
          success: true,
          message: data['message'] ?? 'Mật khẩu đã được đặt lại thành công.',
        );
      } else {
        // Mã 4xx, 5xx (Lỗi từ Server)
        return LoginResponse(
          success: false,
          message: data['message'] ?? 'Token không hợp lệ hoặc đã hết hạn.',
        );
      }
    } catch (e) {
      // Lỗi kết nối mạng (Network failure)
      return LoginResponse(
        success: false,
        message: 'Không thể kết nối đến server.',
      );
    }
  }
}



