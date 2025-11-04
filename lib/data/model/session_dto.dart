class SessionDto {
  final int sessionId;
  final int sectionId;
  final String? date; // LocalDate from backend
  final String classroom;
  final String status;
  final String? content;
  final String? label;
  final String? subjectName;
  final String? startTime; // LocalTime from backend
  final String? endTime;   // LocalTime from backend
  final int? studentCount;
  final bool? isAttendanceCompleted;
  final bool? isContentCompleted;
  final int? presentCount;
  final int? absentCount;

  SessionDto({
    required this.sessionId,
    required this.sectionId,
    this.date,
    required this.classroom,
    required this.status,
    this.content,
    this.label,
    this.subjectName,
    this.startTime,
    this.endTime,
    this.studentCount,
    this.isAttendanceCompleted,
    this.isContentCompleted,
    this.presentCount,
    this.absentCount,
  });

  factory SessionDto.fromJson(Map<String, dynamic> j) => SessionDto(
        sessionId: (j['sessionId'] as num).toInt(),
        sectionId: (j['sectionId'] as num).toInt(),
        date: j['date'] as String?,
        classroom: j['classroom'] as String? ?? '',
        status: j['status'] as String? ?? '',
        content: j['content'] as String?,
        label: j['label'] as String?,
        subjectName: j['subjectName'] as String?,
        startTime: j['startTime'] as String?,
        endTime: j['endTime'] as String?,
        studentCount: (j['studentCount'] as num?)?.toInt(),
        isAttendanceCompleted: j['isAttendanceCompleted'] as bool?,
        isContentCompleted: j['isContentCompleted'] as bool?,
        presentCount: (j['presentCount'] as num?)?.toInt(),
        absentCount: (j['absentCount'] as num?)?.toInt(),
      );
  
  // Helper để format date từ LocalDate (yyyy-MM-dd) sang dd/MM/yyyy
  String get formattedDate {
    if (date == null) return '';
    try {
      final parts = date!.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    } catch (e) {
      // ignore
    }
    return date ?? '';
  }
  
  // Helper để format time từ LocalTime
  String get formattedStartTime {
    if (startTime == null) return '';
    // LocalTime format: HH:mm:ss hoặc HH:mm
    if (startTime!.length >= 5) {
      return startTime!.substring(0, 5);
    }
    return startTime!;
  }
  
  String get formattedEndTime {
    if (endTime == null) return '';
    if (endTime!.length >= 5) {
      return endTime!.substring(0, 5);
    }
    return endTime!;
  }
  
  String get timeRange {
    if (startTime != null && endTime != null) {
      return '$formattedStartTime - $formattedEndTime';
    }
    return '';
  }
}



