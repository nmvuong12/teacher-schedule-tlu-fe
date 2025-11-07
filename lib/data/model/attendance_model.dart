// lib/data/model/attendance_model.dart

import 'dart:convert';

List<Attendance> attendanceFromJson(String str) => List<Attendance>.from(json.decode(str).map((x) => Attendance.fromJson(x)));

String attendanceToJson(List<Attendance> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Attendance {
  final int sessionId;
  final int studentId;
  String status; // có mặt, vắng, muộn
  String? note;

  // Thông tin thêm từ backend (join với bảng student)
  final String studentName;
  final String studentCode; // Mã SV
  final String className;   // Lớp (VD: 64KTPM1)

  Attendance({
    required this.sessionId,
    required this.studentId,
    required this.status,
    this.note,
    required this.studentName,
    required this.studentCode,
    required this.className,
  });

  // Getter tiện lợi để check
  bool get isPresent => status == 'Có mặt';

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
    sessionId: json["sessionId"],
    studentId: json["studentId"],
    status: json["status"] ?? 'Vắng',
    note: json["note"],
    // Các trường này backend phải join và trả về
    studentName: json["studentName"] ?? 'N/A',
    studentCode: json["studentCode"] ?? 'N/A',
    className: json["className"] ?? 'N/A',
  );

  Map<String, dynamic> toJson() => {
    "sessionId": sessionId,
    "studentId": studentId,
    "status": status,
    "note": note,
    // Không cần gửi các trường join ngược lại
    // "studentName": studentName,
    // "studentCode": studentCode,
    // "className": className,
  };
}