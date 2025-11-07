// Student Model
class Student {
  final int studentId;
  final String studentName;
  final String? code; // Mã sinh viên
  final int? userId; // ID của user
  final String? fullName; // Tên đầy đủ từ User
  final int classId;
  final String className;

  Student({
    required this.studentId,
    required this.studentName,
    this.code,
    this.userId,
    this.fullName,
    required this.classId,
    required this.className,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      code: json['code'],
      userId: json['userId'],
      fullName: json['fullName'],
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'code': code,
      'userId': userId,
      'fullName': fullName,
      'classId': classId,
      'className': className,
    };
  }
  
  // Getter để lấy tên hiển thị (ưu tiên fullName từ User)
  String get displayName => fullName ?? studentName;
}


