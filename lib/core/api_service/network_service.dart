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
  // Backend expect username/password trong query parameters
  static Future<LoginResponse> login(String username, String password) async {
    try {
      // Backend expect query parameters (theo error message: "Required request parameter 'username'")
      // URL encode username và password để xử lý ký tự đặc biệt
      final encodedUsername = Uri.encodeQueryComponent(username.trim());
      final encodedPassword = Uri.encodeQueryComponent(password);
      
      // Build URI với query parameters
      final uri = Uri.parse('$baseUrl/auth/login?username=$encodedUsername&password=$encodedPassword');
      
      print('🔐 Login request: POST $uri');
      print('🔐 Username: $username');
      print('🔐 Password length: ${password.length}');
      print('🔐 Password preview: ${password.length > 0 ? password.substring(0, password.length > 10 ? 10 : password.length) + '...' : '(empty)'}');
      print('🔐 Is password hashed? ${password.startsWith('\$2a\$') || password.startsWith('\$2b\$') || password.startsWith('\$2y\$')}');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('📥 Login response status: ${response.statusCode}');
      print('📥 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        print('🔍 Login response data: $userData');
        print('🔍 Full response keys: ${userData.keys.toList()}');
        print('🔍 teacherId in response (teacherId): ${userData['teacherId']}');
        print('🔍 teacherId in response (teacher_id): ${userData['teacher_id']}');
        print('🔍 id in response: ${userData['id']}');
        print('🔍 userId in response: ${userData['userId']}');
        print('🔍 username in response: ${userData['username']}');
        
        var user = UserModel.fromJson(userData);
        print('🔍 UserModel parsed - id: ${user.id}, teacherId: ${user.teacherId}, studentId: ${user.studentId}, username: ${user.username}, role: ${user.role}');
        
        // Nếu role là teacher (1) và teacherId null, thử dùng id làm teacherId
        if (user.role == 1 && user.teacherId == null && user.id > 0) {
          print('⚠️ teacherId is null for teacher role, using id as teacherId');
          user = UserModel(
            id: user.id,
            teacherId: user.id, // Dùng id làm teacherId
            studentId: user.studentId,
            username: user.username,
            password: user.password,
            email: user.email,
            role: user.role,
            fullName: user.fullName,
            department: user.department,
            phone: user.phone,
            isActive: user.isActive,
          );
        }
        
        // Nếu role là student (2) và studentId null, thử dùng id làm studentId
        if (user.role == 2 && user.studentId == null && user.id > 0) {
          print('⚠️ studentId is null for student role, using id as studentId');
          user = UserModel(
            id: user.id,
            teacherId: user.teacherId,
            studentId: user.id, // Dùng id làm studentId
            username: user.username,
            password: user.password,
            email: user.email,
            role: user.role,
            fullName: user.fullName,
            department: user.department,
            phone: user.phone,
            isActive: user.isActive,
          );
        }
        
        print('🔍 Final user before save - id: ${user.id}, teacherId: ${user.teacherId}, username: ${user.username}');
        
        final String token = base64Encode(
          Uint8List.fromList(
            utf8.encode('${user.username}:${user.role}:${DateTime.now().millisecondsSinceEpoch}')
          )
        );
        final userJsonToSave = user.toJson();
        print('🔍 UserJson to save: $userJsonToSave');
        print('🔍 teacherId in userJsonToSave: ${userJsonToSave['teacherId']}');
        await SessionManager.saveSession(token: token, userJson: userJsonToSave);
        
        // Verify saved session
        final (_, savedUserJson) = await SessionManager.loadSession();
        print('✅ Session saved - verifying...');
        print('📦 Saved userJson: $savedUserJson');
        print('📦 teacherId in saved JSON: ${savedUserJson?['teacherId']}');
        print('📦 id in saved JSON: ${savedUserJson?['id']}');
        
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
          final errorMessage = error['error'] ?? error['message'] ?? 'Tài khoản hoặc mật khẩu không chính xác';
          
          print('❌ Login failed: $errorMessage');
          print('❌ Response status: ${response.statusCode}');
          print('❌ Response body: ${response.body}');
          
          return LoginResponse(
            success: false,
            message: errorMessage,
          );
        } catch (e) {
          print('❌ Error parsing error response: $e');
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



