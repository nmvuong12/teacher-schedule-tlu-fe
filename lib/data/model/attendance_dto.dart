class AttendanceDto {
  final int? sessionId;
  final int? studentId;
  final String? studentName;
  final String status; // 'PRESENT', 'ABSENT', 'Vắng', 'Có mặt', etc.
  final String? date; // Ngày học (format: "2024-10-07")
  final String? label; // Nhãn buổi học (VD: "Buổi 1")

  AttendanceDto({
    this.sessionId,
    this.studentId,
    this.studentName,
    required this.status,
    this.date,
    this.label,
  });

  factory AttendanceDto.fromJson(Map<String, dynamic> j) => AttendanceDto(
        sessionId: (j['sessionId'] as num?)?.toInt(),
        studentId: (j['studentId'] as num?)?.toInt(),
        studentName: j['studentName'] as String?,
        status: j['status'] as String? ?? 'UNKNOWN',
        date: j['date'] as String?,
        label: j['label'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (sessionId != null) 'sessionId': sessionId,
        if (studentId != null) 'studentId': studentId,
        if (studentName != null) 'studentName': studentName,
        'status': status,
        if (date != null) 'date': date,
        if (label != null) 'label': label,
      };

  // Helper methods
  bool get isPresent => status == 'PRESENT' || status == 'Có mặt';
  bool get isAbsent => status == 'ABSENT' || status == 'Vắng';

  String get statusText {
    switch (status) {
      case 'PRESENT':
      case 'Có mặt':
        return 'Có mặt';
      case 'ABSENT':
      case 'Vắng':
        return 'Vắng';
      default:
        return 'Chưa điểm danh';
    }
  }

  String get statusIcon {
    switch (status) {
      case 'PRESENT':
      case 'Có mặt':
        return '✅';
      case 'ABSENT':
      case 'Vắng':
        return '❌';
      default:
        return '❓';
    }
  }
}
