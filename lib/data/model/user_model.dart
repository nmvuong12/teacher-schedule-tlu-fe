import 'dart:convert'; // Import này cần cho LoginResponse (nếu dùng http)

class UserModel {
  final int id;
  final int? teacherId;
  final String username;
  final String? password; // [SỬA 1] - Thêm password (giống code cũ)
  final String email;
  final int role;
  final String? fullName;
  final String? department;
  final String? phone;
  final bool isActive;

  UserModel({
    required this.id,
    this.teacherId,
    required this.username,
    this.password, // [SỬA 2] - Thêm password vào constructor
    required this.email,
    required this.role,
    this.fullName,
    this.department,
    this.phone,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('🔍 DEBUG: UserModel.fromJson called with: $json');

    return UserModel(
      id: json['userId'] ?? json['id'] ?? 0,
      teacherId: json['teacherId'],
      username: json['userName'] ?? json['username'] ?? '',
      password: json['password'], // [SỬA 3] - Đọc password (dù server thường không gửi)
      email: json['email'] ?? '',
      role: json['role'] ?? 1,
      fullName: json['fullName'] ?? json['full_name'] ?? json['name'],
      department: json['department'],
      phone: json['phone'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'teacherId': teacherId,
      'username': username,
      'email': email,
      'role': role,
      'fullName': fullName,
      'department': department,
      'phone': phone,
      'isActive': isActive,
    };

    // [SỬA 4] - Chỉ thêm password vào JSON nếu nó được cung cấp
    // (Giống logic code cũ)
    if (password != null && password!.isNotEmpty) {
      json['password'] = password;
    }

    return json;
  }

  bool get isAdmin => role == 0;
  bool get isTeacher => role == 1;
  bool get isStudent => role == 2;

  String get roleName {
    switch (role) {
      case 0:
        return 'Admin';
      case 1:
        return 'Giảng viên';
      case 2:
        return 'Sinh viên';
      default:
        return 'Không xác định';
    }
  }
}

// ... (LoginRequest và LoginResponse giữ nguyên) ...

// Lớp dùng để định nghĩa payload gửi đi khi đăng nhập
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

// Lớp dùng để định nghĩa phản hồi nhận được từ API sau khi đăng nhập
class LoginResponse {
  final bool success;
  final String? message;
  final UserModel? user;
  final String? token;

  LoginResponse({
    required this.success,
    this.message,
    this.user,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 DEBUG: LoginResponse.fromJson called with: $json');

    UserModel? user;
    if (json['user'] != null) {
      user = UserModel.fromJson(json['user']);
    } else if (json['data'] != null) {
      user = UserModel.fromJson(json['data']);
    } else if (json.containsKey('id') || json.containsKey('userId')) {
      user = UserModel.fromJson(json);
    }

    return LoginResponse(
      success: json['success'] ?? json['status'] == 'success' ?? !json.containsKey('error'),
      message: json['message'] ?? json['msg'] ?? json['error'],
      user: user,
      token: json['token'] ?? json['access_token'],
    );
  }
}