// Model riêng cho màn hình student attendance (có đầy đủ thông tin session)
class StudentAttendanceView {
  final int sessionId;
  final int studentId;
  final String studentName;
  final String status;
  
  // Thông tin session
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? classroom;
  final String? label;
  final String? markedAt;
  final String? note;

  StudentAttendanceView({
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.status,
    this.date,
    this.startTime,
    this.endTime,
    this.classroom,
    this.label,
    this.markedAt,
    this.note,
  });

  // Helper methods
  bool get isPresent => status == 'PRESENT';
  bool get isAbsent => status == 'ABSENT';

  String get statusText {
    switch (status) {
      case 'PRESENT':
        return 'Có mặt';
      case 'ABSENT':
        return 'Vắng';
      case 'NOT_MARKED':
        return 'Chưa điểm danh';
      default:
        return 'Chưa điểm danh';
    }
  }

  String get statusIcon {
    switch (status) {
      case 'PRESENT':
        return '✅';
      case 'ABSENT':
        return '❌';
      default:
        return '❓';
    }
  }

  String get timeRange {
    if (startTime != null && endTime != null) {
      final start = startTime!.length >= 5 ? startTime!.substring(0, 5) : startTime!;
      final end = endTime!.length >= 5 ? endTime!.substring(0, 5) : endTime!;
      return '$start - $end';
    }
    return '';
  }
}






