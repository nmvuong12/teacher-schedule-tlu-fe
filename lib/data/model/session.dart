// Session Model (Buổi học)
class Session {
  final int? sessionId;
  final int sectionId;
  final DateTime date;
  final String classroom;
  final String status;
  final String content;
  final String label;
  final DateTime startTime;
  final DateTime endTime;
  final String? subjectName;  // ✅ Tên môn học
  final String? sectionName;  // ✅ Tên học phần (Môn học - Lớp)

  Session({
    this.sessionId,
    required this.sectionId,
    required this.date,
    required this.classroom,
    required this.status,
    required this.content,
    required this.label,
    required this.startTime,
    required this.endTime,
    this.subjectName,
    this.sectionName,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['sessionId'],
      sectionId: json['sectionId'] ?? 0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      classroom: json['classroom'] ?? '',
      status: json['status'] ?? '',
      content: json['content'] ?? '',
      label: json['label'] ?? '',
      startTime: DateTime.parse('1970-01-01T${json['startTime'] ?? '00:00:00'}'),
      endTime: DateTime.parse('1970-01-01T${json['endTime'] ?? '00:00:00'}'),
      subjectName: json['subjectName'],   // ✅ Parse subjectName từ API
      sectionName: json['sectionName'],   // ✅ Parse sectionName từ API
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
      'startTime': startTime.toIso8601String().split('T')[1].substring(0, 8),
      'endTime': endTime.toIso8601String().split('T')[1].substring(0, 8),
    };
    
    // Only include sessionId if it's not null (for updates)
    if (sessionId != null) {
      json['sessionId'] = sessionId!;
    }
    
    return json;
  }

  String get timeRange {
    final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }
}


