class UserModel {
  final int id;
  final String username;
  final String email;
  final int role;
  final String? fullName;
  final String? department;
  final String? phone;
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
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
      // Handles keys 'userId' or 'id'
      id: json['userId'] ?? json['id'] ?? 0,
      // Handles keys 'userName' or 'username'
      username: json['userName'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      // Default to teacher (1) if role is missing
      role: json['role'] ?? 1,
      // Handles keys 'fullName', 'full_name', or 'name'
      fullName: json['fullName'] ?? json['full_name'] ?? json['name'],
      department: json['department'],
      phone: json['phone'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'fullName': fullName,
      'department': department,
      'phone': phone,
      'isActive': isActive,
    };
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
    // Kiểm tra các key phổ biến chứa đối tượng người dùng
    if (json['user'] != null) {
      user = UserModel.fromJson(json['user']);
    } else if (json['data'] != null) {
      user = UserModel.fromJson(json['data']);
    } else if (json.containsKey('id') || json.containsKey('userId')) {
      // Nếu phản hồi là đối tượng người dùng trực tiếp
      user = UserModel.fromJson(json);
    }

    return LoginResponse(
      // Kiểm tra các key phổ biến xác định thành công
      success: json['success'] ?? json['status'] == 'success' ?? !json.containsKey('error'),
      // Kiểm tra các key phổ biến chứa thông báo
      message: json['message'] ?? json['msg'] ?? json['error'],
      user: user,
      // Kiểm tra các key phổ biến chứa token
      token: json['token'] ?? json['access_token'],
    );
  }
}