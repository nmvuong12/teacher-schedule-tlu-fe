// [session_model.dart] - ĐÃ SỬA LỖI HÀM _parseTime
import 'dart:convert';
import 'package:flutter/material.dart';

// Hàm helper để parse một danh sách Session từ JSON string
List<Session> sessionFromJson(String str) => List<Session>.from(json.decode(str).map((x) => Session.fromJson(x)));

// Enum để quản lý status
enum SessionStatus {
  pending,          // Đã lên lịch
  completed,        // Đã hoàn thành
  cancelled,        // Đã hủy
  requestedLeave,   // Đã yêu cầu xin nghỉ
  inProgress,       // ✅ Đã thêm: Đang diễn ra
  rejectedPending,  // Từ chối - Đã lên lịch
  unknown,          // Không xác định
}

// Session Model (Buổi học) - ĐÃ GỘP
class Session {
  final int? sessionId;
  final int sectionId;
  final DateTime date;
  final String classroom;
  String status; // Để `status` có thể thay đổi được
  final String? content;
  final String? label;
  final DateTime startTime; // <-- Dùng DateTime
  final DateTime endTime;   // <-- Dùng DateTime

  // Các trường từ session.dart
  final String? subjectName;
  final String? className; // <-- Đổi tên từ sectionName
  final String? sectionName; // Tên học phần từ CourseSection

  // Các trường từ session_model.dart
  final int? studentCount;
  final bool? isAttendanceCompleted;
  final bool? isContentCompleted;
  final int? presentCount; // Số SV có mặt
  final int? absentCount;  // Số SV vắng

  Session({
    this.sessionId,
    required this.sectionId,
    required this.date,
    required this.classroom,
    required this.status,
    this.content,
    this.label,
    required this.startTime,
    required this.endTime,
    this.subjectName,
    this.className, // <-- Đổi tên từ sectionName
    this.sectionName, // Tên học phần
    this.studentCount,
    this.isAttendanceCompleted,
    this.isContentCompleted,
    this.presentCount,
    this.absentCount,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    // Helper parse int an toàn
    int _parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // ⭐️ [SỬA LỖI] ⭐️
    // Hàm _parseTime mới, an toàn hơn để xử lý các định dạng HH:mm
    DateTime _parseTime(dynamic timeStr) {
      if (timeStr is! String) {
        return DateTime.parse('1970-01-01T00:00:00');
      }

      try {
        // Thử parse trực tiếp nếu là định dạng chuẩn (HH:mm:ss)
        if (timeStr.length == 8) {
          return DateTime.parse('1970-01-01T$timeStr');
        }

        // Xử lý các định dạng rút gọn như HH:mm (14:30) hoặc H:m (9:5)
        final parts = timeStr.split(':');
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        final second = int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0;

        // Tạo lại chuỗi an toàn
        final safeTimeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

        return DateTime.parse('1970-01-01T$safeTimeStr');

      } catch (e) {
        debugPrint('Lỗi _parseTime với giá trị "$timeStr": $e');
        return DateTime.parse('1970-01-01T00:00:00');
      }
    }

    return Session(
      sessionId: json['sessionId'], // Giữ là int?
      sectionId: _parseInt(json["sectionId"]),
      // LocalDate của Java khi parse ("YYYY-MM-DD") là hợp lệ
      date: DateTime.parse(json["date"] ?? DateTime.now().toIso8601String()),
      classroom: json["classroom"] ?? 'N/A',
      status: json["status"] ?? 'unknown',
      content: json["content"],
      label: json["label"],

      // Dùng hàm _parseTime đã sửa lỗi
      startTime: _parseTime(json['startTime']),
      endTime: _parseTime(json['endTime']),

      // Các trường đã gộp (Tên đã khớp với SessionDTO.java)
      subjectName: json["subjectName"],
      className: json["className"], // Tên lớp
      sectionName: json["sectionName"], // Tên học phần (từ CourseSection.sectionName)
      studentCount: json["studentCount"] == null ? null : _parseInt(json["studentCount"]),
      isAttendanceCompleted: json["isAttendanceCompleted"],
      isContentCompleted: json["isContentCompleted"],
      presentCount: json["presentCount"] == null ? null : _parseInt(json["presentCount"]),
      absentCount: json["absentCount"] == null ? null : _parseInt(json["absentCount"]),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'sectionId': sectionId,
      'date': date.toIso8601String().split('T')[0],
      'classroom': classroom,
      'status': status,
      'content': content,
      'label': label,
      // Chuyển DateTime về lại string HH:mm:ss
      'startTime': startTime.toIso8601String().split('T')[1].substring(0, 8),
      'endTime': endTime.toIso8601String().split('T')[1].substring(0, 8),

      // Các trường đã gộp
      "subjectName": subjectName,
      "className": className,
      "sectionName": sectionName,
      "studentCount": studentCount,
      "isAttendanceCompleted": isAttendanceCompleted,
      "isContentCompleted": isContentCompleted,
      "presentCount": presentCount,
      "absentCount": absentCount,
    };

    if (sessionId != null) {
      json['sessionId'] = sessionId!;
    }

    return json;
  }

  // Getter để lấy tên hiển thị (ưu tiên sectionName từ CourseSection)
  String? get displaySectionName => sectionName ?? className ?? subjectName;

  // Getter 'timeRange' từ session.dart (giờ đã hoạt động)
  String get timeRange {
    final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  // Hàm 'getStatusInfo' từ session_model.dart
  Map<String, dynamic> getStatusInfo() {
    // ✅✅✅ BỔ SUNG TRẠNG THÁI "Đang diễn ra" VÀO ĐÂY ✅✅✅
    switch (status) {
      case 'Đang diễn ra':
        return {'text': 'Đang diễn ra', 'color': Colors.green.shade600, 'enum': SessionStatus.inProgress};
      case 'Đã lên lịch':
        return {'text': 'Đã lên lịch', 'color': Colors.blue, 'enum': SessionStatus.pending};
      case 'Đã hoàn thành':
        return {'text': 'Đã hoàn thành', 'color': Colors.green, 'enum': SessionStatus.completed};
      case 'Đã hủy':
        return {'text': 'Đã hủy', 'color': Colors.grey, 'enum': SessionStatus.cancelled};
      case 'Đã yêu cầu xin nghỉ':
        return {'text': 'Đã yêu cầu xin nghỉ', 'color': Colors.orange, 'enum': SessionStatus.requestedLeave};
      case 'Từ chối xin nghỉ - Đã lên lịch':
        return {'text': 'Từ chối xin nghỉ - Đã lên lịch', 'color': Colors.red, 'enum': SessionStatus.rejectedPending};
      default:
      // Sửa màu mặc định cho dễ nhìn hơn
        return {'text': 'Không xác định ($status)', 'color': Colors.black54, 'enum': SessionStatus.unknown};
    }
  }
}