// Teacher Model
class Teacher {
  final int? teacherId;
  final int userId;
  final String userName;
  final String department;
  final int totalTeachingHours;

  Teacher({
    this.teacherId,
    required this.userId,
    required this.userName,
    required this.department,
    required this.totalTeachingHours,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      teacherId: json['teacherId'],
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      department: json['department'] ?? '',
      totalTeachingHours: json['totalTeachingHours'] ?? 0,
    );
  }

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


