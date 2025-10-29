// Student Model
class Student {
  final int studentId;
  final String studentName;
  final int classId;
  final String className;

  Student({
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.className,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'className': className,
    };
  }
}


