// Teacher Model
class Teacher {
  final int? teacherId;
  final int userId;
  final String userName;
  final String? fullName; // Tên đầy đủ từ User
  final String? code; // Mã giảng viên
  final String department;
  final int totalTeachingHours;

  Teacher({
    this.teacherId,
    required this.userId,
    required this.userName,
    this.fullName,
    this.code,
    required this.department,
    required this.totalTeachingHours,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      teacherId: json['teacherId'],
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      fullName: json['fullName'],
      code: json['code'],
      department: json['department'] ?? '',
      totalTeachingHours: json['totalTeachingHours'] ?? 0,
    );
  }
  
  // Getter để lấy tên hiển thị (ưu tiên fullName từ User)
  String get displayName => fullName ?? userName;

  Map<String, dynamic> toJson() {
    final json = {
      'userId': userId,
      'userName': userName,
      'department': department,
      'totalTeachingHours': totalTeachingHours,
    };
    
    // Only include teacherId if it's not null (for updates)
    if (teacherId != null) {
      json['teacherId'] = teacherId!;
    }
    
    return json;
  }
}


