class TeachingLeaveDto {
  final int sessionId;
  final String reason;
  final String expectedMakeupDate; // yyyy-MM-dd
  final int status;

  TeachingLeaveDto({
    required this.sessionId,
    required this.reason,
    required this.expectedMakeupDate,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'reason': reason,
        'expectedMakeupDate': expectedMakeupDate,
        'status': status,
      };

  factory TeachingLeaveDto.fromJson(Map<String, dynamic> j) => TeachingLeaveDto(
        sessionId: (j['sessionId'] as num).toInt(),
        reason: j['reason'] as String? ?? '',
        expectedMakeupDate: j['expectedMakeupDate'] as String? ?? '',
        status: (j['status'] as num?)?.toInt() ?? 0,
      );
}


