class SectionDto {
  final int sectionId;
  final String subjectName;
  final String? weeklySessions;
  final String? className;
  final String? semester;
  final String? shift;
  final String? teacherName;

  SectionDto({
    required this.sectionId,
    required this.subjectName,
    this.weeklySessions,
    this.className,
    this.semester,
    this.shift,
    this.teacherName,
  });

  factory SectionDto.fromJson(Map<String, dynamic> j) => SectionDto(
        sectionId: (j['sectionId'] as num).toInt(),
        subjectName: j['subjectName'] as String? ?? '',
        weeklySessions: j['weeklySessions'] as String?,
        className: j['className'] as String?,
        semester: j['semester'] as String?,
        shift: j['shift'] as String?,
        teacherName: j['teacherName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'sectionId': sectionId,
        'subjectName': subjectName,
        'weeklySessions': weeklySessions,
        'className': className,
        'semester': semester,
        'shift': shift,
        'teacherName': teacherName,
      };
}
