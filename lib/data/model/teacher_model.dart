// [teacher_model.dart] - ĐÃ SỬA LỖI
// (Giả sử file này nằm trong data/model/)

class Teacher {
  final int? teacherId;
  final int userId; // Đây là ID liên kết tới UserModel
  final String username; // [SỬA 1] - Đổi 'userName' -> 'username'
  final String? fullName; // Thêm fullName để tiện hiển thị
  final String department;
  final int totalTeachingHours;

  Teacher({
    this.teacherId,
    required this.userId,
    required this.username, // [SỬA 2] - Đổi 'userName' -> 'username'
    this.fullName,
    required this.department,
    required this.totalTeachingHours,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      teacherId: json['teacherId'],
      // [SỬA 3] - Đọc 'userId' hoặc 'id' từ JSON (giống UserModel)
      userId: json['userId'] ?? json['id'] ?? 0,
      // [SỬA 4] - Đọc 'userName' hoặc 'username' (giống UserModel)
      username: json['userName'] ?? json['username'] ?? '',
      fullName: json['fullName'],
      department: json['department'] ?? '',
      totalTeachingHours: json['totalTeachingHours'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'userId': userId,
      'username': username, // [SỬA 5] - Đổi 'userName' -> 'username'
      'fullName': fullName,
      'department': department,
      'totalTeachingHours': totalTeachingHours,
    };
  }
}