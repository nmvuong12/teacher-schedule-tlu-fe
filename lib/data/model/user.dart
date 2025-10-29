// User Model
class User {
  final int? userId;
  final String userName;
  final String password;
  final String fullName;
  final String email;
  final int role;

  User({
    this.userId,
    required this.userName,
    required this.password,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      userName: json['userName'] ?? '',
      password: json['password'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'userName': userName,
      'password': password,
      'fullName': fullName,
      'email': email,
      'role': role,
    };
    
    // Only include userId if it's not null (for updates)
    if (userId != null) {
      json['userId'] = userId!;
    }
    
    return json;
  }

  String get roleName {
    switch (role) {
      case 1:
        return 'Administrator';
      case 2:
        return 'Teacher';
      case 3:
        return 'Student';
      default:
        return 'Unknown';
    }
  }
}


