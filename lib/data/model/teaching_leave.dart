// Teaching Leave Model (Đơn xin nghỉ)
class TeachingLeave {
  final int sessionId;
  final String reason;
  final DateTime expectedMakeupDate;
  final int status;

  TeachingLeave({
    required this.sessionId,
    required this.reason,
    required this.expectedMakeupDate,
    required this.status,
  });

  factory TeachingLeave.fromJson(Map<String, dynamic> json) {
    return TeachingLeave(
      sessionId: json['sessionId'] ?? 0,
      reason: json['reason'] ?? '',
      expectedMakeupDate: DateTime.parse(json['expectedMakeupDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'reason': reason,
      'expectedMakeupDate': expectedMakeupDate.toIso8601String().split('T')[0],
      'status': status,
    };
  }

  String get statusName {
    switch (status) {
      case 0:
        return 'Chờ duyệt';
      case 1:
        return 'Đã phê duyệt';
      case 2:
        return 'Từ chối';
      default:
        return 'Không xác định';
    }
  }
}


