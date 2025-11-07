// Teacher Model - ✅ Đã cập nhật đầy đủ các trường
class Teacher {
  final int? teacherId;
  final int userId;
  final String userName;
  final String? fullName; // Tên đầy đủ từ User
  final String? code; // Mã giảng viên
  final String department;
  final int totalTeachingHours;
  
  // ✅ Additional profile fields
  final String? degree; // Học vị
  final String? workplace; // Nơi làm việc
  final String? specialization; // Chuyên ngành
  final String? phone; // Số điện thoại
  final String? office; // Văn phòng
  final String? email; // Email
  final String? teachingSubjects; // Môn học giảng dạy
  final String? researchFields; // Lĩnh vực nghiên cứu
  final String? address; // Địa chỉ
  
  // ✅ New profile fields
  final String? avatarUrl; // URL ảnh đại diện
  final String? title; // Chức danh
  final String? bio; // Tiểu sử
  final String? dateOfBirth; // Ngày sinh (format: yyyy-MM-dd)
  final String? gender; // Giới tính

  Teacher({
    this.teacherId,
    required this.userId,
    required this.userName,
    this.fullName,
    this.code,
    required this.department,
    required this.totalTeachingHours,
    this.degree,
    this.workplace,
    this.specialization,
    this.phone,
    this.office,
    this.email,
    this.teachingSubjects,
    this.researchFields,
    this.address,
    this.avatarUrl,
    this.title,
    this.bio,
    this.dateOfBirth,
    this.gender,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      teacherId: json['teacherId'],
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      fullName: json['fullName'],
      code: json['code'],
      department: json['department'] ?? '',
      totalTeachingHours: json['totalTeachingHours'] ?? 0,
      degree: json['degree'],
      workplace: json['workplace'],
      specialization: json['specialization'],
      phone: json['phone'],
      office: json['office'],
      email: json['email'],
      teachingSubjects: json['teachingSubjects'],
      researchFields: json['researchFields'],
      address: json['address'],
      avatarUrl: json['avatarUrl'],
      title: json['title'],
      bio: json['bio'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
    );
  }
  
  // Getter để lấy tên hiển thị (ưu tiên fullName từ User)
  String get displayName => fullName ?? userName;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'department': department,
      'totalTeachingHours': totalTeachingHours,
    };
    
    // Only include teacherId if it's not null (for updates)
    if (teacherId != null) {
      json['teacherId'] = teacherId!;
    }
    
    // ✅ Thêm các trường optional (chỉ thêm nếu có giá trị)
    if (code != null && code!.isNotEmpty) json['code'] = code;
    if (degree != null && degree!.isNotEmpty) json['degree'] = degree;
    if (workplace != null && workplace!.isNotEmpty) json['workplace'] = workplace;
    if (specialization != null && specialization!.isNotEmpty) json['specialization'] = specialization;
    if (phone != null && phone!.isNotEmpty) json['phone'] = phone;
    if (office != null && office!.isNotEmpty) json['office'] = office;
    if (email != null && email!.isNotEmpty) json['email'] = email;
    if (teachingSubjects != null && teachingSubjects!.isNotEmpty) json['teachingSubjects'] = teachingSubjects;
    if (researchFields != null && researchFields!.isNotEmpty) json['researchFields'] = researchFields;
    if (address != null && address!.isNotEmpty) json['address'] = address;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) json['avatarUrl'] = avatarUrl;
    if (title != null && title!.isNotEmpty) json['title'] = title;
    if (bio != null && bio!.isNotEmpty) json['bio'] = bio;
    if (dateOfBirth != null && dateOfBirth!.isNotEmpty) json['dateOfBirth'] = dateOfBirth;
    if (gender != null && gender!.isNotEmpty) json['gender'] = gender;
    
    return json;
  }
  
  // ✅ CopyWith method để tạo bản copy với một số thay đổi
  Teacher copyWith({
    int? teacherId,
    int? userId,
    String? userName,
    String? fullName,
    String? code,
    String? department,
    int? totalTeachingHours,
    String? degree,
    String? workplace,
    String? specialization,
    String? phone,
    String? office,
    String? email,
    String? teachingSubjects,
    String? researchFields,
    String? address,
    String? avatarUrl,
    String? title,
    String? bio,
    String? dateOfBirth,
    String? gender,
  }) {
    return Teacher(
      teacherId: teacherId ?? this.teacherId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      code: code ?? this.code,
      department: department ?? this.department,
      totalTeachingHours: totalTeachingHours ?? this.totalTeachingHours,
      degree: degree ?? this.degree,
      workplace: workplace ?? this.workplace,
      specialization: specialization ?? this.specialization,
      phone: phone ?? this.phone,
      office: office ?? this.office,
      email: email ?? this.email,
      teachingSubjects: teachingSubjects ?? this.teachingSubjects,
      researchFields: researchFields ?? this.researchFields,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }
}


