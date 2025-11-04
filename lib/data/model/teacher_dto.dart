class TeacherDto {
  final int teacherId;
  final int userId;
  final String userName;
  final String department;
  final int totalTeachingHours;

  // Additional profile fields (may be null)
  final String? fullName; // Tên đầy đủ (ví dụ: "Nguyễn Văn A")
  final String? degree;
  final String? workplace;
  final String? specialization;
  final String? phone;
  final String? office;
  final String? email;
  final String? teachingSubjects; // raw string from backend
  final String? researchFields; // raw string from backend
  final String? address;

  TeacherDto({
    required this.teacherId,
    required this.userId,
    required this.userName,
    required this.department,
    required this.totalTeachingHours,
    this.fullName,
    this.degree,
    this.workplace,
    this.specialization,
    this.phone,
    this.office,
    this.email,
    this.teachingSubjects,
    this.researchFields,
    this.address,
  });

  factory TeacherDto.fromJson(Map<String, dynamic> j) => TeacherDto(
        teacherId: (j['teacherId'] as num).toInt(),
        userId: (j['userId'] as num).toInt(),
        userName: j['userName'] as String? ?? '',
        department: j['department'] as String? ?? '',
        totalTeachingHours: (j['totalTeachingHours'] as num?)?.toInt() ?? 0,
        fullName: j['fullName'] as String?,
        degree: j['degree'] as String?,
        workplace: j['workplace'] as String?,
        specialization: j['specialization'] as String?,
        phone: j['phone'] as String?,
        office: j['office'] as String?,
        email: j['email'] as String?,
        teachingSubjects: j['teachingSubjects'] as String?,
        researchFields: j['researchFields'] as String?,
        address: j['address'] as String?,
      );

  List<String> parseSubjects() {
    if (teachingSubjects == null || teachingSubjects!.trim().isEmpty) return [];
    return teachingSubjects!
        .split(RegExp(r'[\n,;]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<String> parseResearchAreas() {
    if (researchFields == null || researchFields!.trim().isEmpty) return [];
    return researchFields!
        .split(RegExp(r'[\n,;]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}



























