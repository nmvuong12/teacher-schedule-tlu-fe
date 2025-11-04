class AttendanceDto {
  final int sessionId;
  final int studentId;
  final String studentName;
  final String status; // 'PRESENT', 'ABSENT'

  AttendanceDto({
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.status,
  });

  factory AttendanceDto.fromJson(Map<String, dynamic> j) => AttendanceDto(
        sessionId: (j['sessionId'] as num).toInt(),
        studentId: (j['studentId'] as num).toInt(),
        studentName: j['studentName'] as String? ?? '',
        status: j['status'] as String? ?? 'UNKNOWN',
      );

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'studentId': studentId,
        'studentName': studentName,
        'status': status,
      };

  // Helper methods
  bool get isPresent => status == 'PRESENT';
  bool get isAbsent => status == 'ABSENT';

  String get statusText {
    switch (status) {
      case 'PRESENT':
        return 'Có mặt';
      case 'ABSENT':
        return 'Vắng';
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
}

