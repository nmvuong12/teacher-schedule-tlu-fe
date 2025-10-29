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
      if (value == null) return 'sáng';
      if (value is int) {
        switch (value) {
          case 1: return 'sáng';
          case 2: return 'chiều';
          case 3: return 'tối';
          case 4: return 'tối';
          default: return 'sáng';
        }
      }
      final s = value.toString().trim().toLowerCase();
      switch (s) {
        case 'sáng':
        case 'ca 1':
        case '1':
        case 'morning':
          return 'sáng';
        case 'chiều':
        case 'ca 2':
        case '2':
        case 'afternoon':
          return 'chiều';
        case 'tối':
        case 'ca 3':
        case 'ca 4':
        case '3':
        case '4':
        case 'evening':
          return 'tối';
        default:
          return 'sáng';
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
    final Map<String, dynamic> json = {
      'classId': classId,
      'className': className,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'semester': semester,
      'shift': shift,
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
    switch (shift.toLowerCase()) {
      case 'sáng':
        return 'Sáng';
      case 'chiều':
        return 'Chiều';
      case 'tối':
        return 'Tối';
      default:
        return 'Không xác định';
    }
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


