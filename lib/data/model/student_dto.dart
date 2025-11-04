class StudentDto {
  final int id;
  final int? studentId;
  final String? studentName;
  final String? fullName;
  final String? email;
  final int? classId;
  final String? className;

  StudentDto({
    required this.id,
    this.studentId,
    this.studentName,
    this.fullName,
    this.email,
    this.classId,
    this.className,
  });

  factory StudentDto.fromJson(Map<String, dynamic> json) {
    return StudentDto(
      id: json['id'] ?? json['studentId'] ?? 0,
      studentId: json['studentId'] ?? json['id'],
      studentName: json['studentName'] ?? json['fullName'] ?? json['name'],
      fullName: json['fullName'] ?? json['studentName'] ?? json['name'],
      email: json['email'],
      classId: json['classId'] ?? json['class_id'],
      className: json['className'] ?? json['class_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName ?? fullName,
      'fullName': fullName ?? studentName,
      'email': email,
      'classId': classId,
      'className': className,
    };
  }
}
