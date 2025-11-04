// Course Section Model (Học phần)
class CourseSection {
  final int? sectionId;
  final String? sectionName;  // ✅ Tên học phần (auto-generated: Môn học - Lớp)
  final int classId;
  final String className;
  final int subjectId;
  final String subjectName;
  final String semester;
  final String shift;
  final DateTime startDate;
  final DateTime endDate;
  final String weeklySessions;
  final String? status;  // ✅ Trạng thái: "Đang hoạt động", "Đã hủy", "Đã kết thúc"
  final int teacherId;
  final String teacherName;
  final String? classroom; // ✅ Phòng học mặc định cho các buổi

  CourseSection({
    this.sectionId,
    this.sectionName,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.semester,
    required this.shift,
    required this.startDate,
    required this.endDate,
    required this.weeklySessions,
    this.status,
    required this.teacherId,
    required this.teacherName,
    this.classroom,
  });

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    String _parseShift(dynamic value) {
      // Normalize to numeric string '1'..'4' for FE controls
      if (value == null) return '1';
      if (value is int) {
        return value.clamp(1,4).toString();
      }
      final s = value.toString().trim().toLowerCase();
      if (RegExp(r'^[1-4]$').hasMatch(s)) return s;
      switch (s) {
        case 'sáng':
        case 'morning':
        case 'ca 1':
          return '1';
        case 'chiều':
        case 'afternoon':
        case 'ca 2':
          return '2';
        case 'tối':
        case 'evening':
        case 'ca 3':
          return '3';
        case 'ca 4':
          return '4';
        default:
          return '1';
      }
    }

    DateTime _parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return DateTime.now();
      return DateTime.parse(value.toString());
    }

    String _toStringValue(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return CourseSection(
      sectionId: json['sectionId'],
      sectionName: json['sectionName'],  // ✅ Parse sectionName from API
      classId: json['classId'] ?? 0,
      className: _toStringValue(json['className']),
      subjectId: json['subjectId'] ?? 0,
      subjectName: _toStringValue(json['subjectName']),
      semester: _toStringValue(json['semester']),
      shift: _parseShift(json['shift']),
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      weeklySessions: _toStringValue(json['weeklySessions']),
      status: json['status'],  // ✅ Parse status from API
      teacherId: json['teacherId'] ?? 0,
      teacherName: _toStringValue(json['teacherName']),
      classroom: _toStringValue(json['classroom']).isEmpty ? null : _toStringValue(json['classroom']),
    );
  }

  Map<String, dynamic> toJson() {
    String _normalizeShiftForApi(String value) {
      final v = value.trim().toLowerCase();
      // Already numeric 1-4
      if (RegExp(r'^[1-4]$').hasMatch(v)) return v;
      // Map legacy labels to numeric
      switch (v) {
        case 'sáng':
        case 'morning':
        case 'ca 1':
          return '1';
        case 'chiều':
        case 'afternoon':
        case 'ca 2':
          return '2';
        case 'tối':
        case 'evening':
        case 'ca 3':
          return '3';
        case 'ca 4':
          return '4';
        default:
          return '1';
      }
    }
    final Map<String, dynamic> json = {
      'classId': classId,
      'className': className,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'semester': semester,
      'shift': _normalizeShiftForApi(shift),
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      'weeklySessions': weeklySessions,
      'status': status,
      'teacherId': teacherId,
      'teacherName': teacherName,
    };
    
    // Only include sectionId if it's not null (for updates)
    if (sectionId != null) {
      json['sectionId'] = sectionId!;
    }
    if (classroom != null && classroom!.trim().isNotEmpty) {
      json['classroom'] = classroom;
    }
    
    return json;
  }

  String get shiftName {
    switch (shift) {
      case '1':
        return 'Ca 1 (07:00 - 09:35)';
      case '2':
        return 'Ca 2 (09:40 - 12:25)';
      case '3':
        return 'Ca 3 (12:55 - 15:35)';
      case '4':
        return 'Ca 4 (15:40 - 18:20)';
      default:
        return 'Ca ?';
    }
  }

  String get weeklySessionsLabel {
    if (weeklySessions.trim().isEmpty) return '';
    final parts = weeklySessions.split(',');
    final labels = <String>[];
    for (final p in parts) {
      switch (p.trim()) {
        case '2': labels.add('Hai'); break;
        case '3': labels.add('Ba'); break;
        case '4': labels.add('Tư'); break;
        case '5': labels.add('Năm'); break;
        case '6': labels.add('Sáu'); break;
        case '7': labels.add('Bảy'); break;
        case '8': labels.add('Chủ nhật'); break;
        default: if (p.trim().isNotEmpty) labels.add(p.trim());
      }
    }
    return labels.join(', ');
  }

  // ✅ Getter tính toán trạng thái dựa trên thời gian (fallback nếu API không trả về)
  String get autoStatus {
    final now = DateTime.now();
    if (now.isBefore(startDate)) {
      return 'Chưa bắt đầu';
    } else if (now.isAfter(endDate)) {
      return 'Kết thúc';
    } else {
      return 'Đang diễn ra';
    }
  }
  
  // ✅ Getter status: Ưu tiên status từ API, nếu null thì dùng autoStatus
  String get displayStatus => status ?? autoStatus;
}


