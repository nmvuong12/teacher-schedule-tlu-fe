// [teacher_model.dart] - ĐÃ SỬA LỖI - Thêm đầy đủ các field
// (Giả sử file này nằm trong data/model/)

class Teacher {
  final int? teacherId;
  final int userId; // Đây là ID liên kết tới UserModel
  final String userName; // Tên người dùng
  final String? fullName; // Thêm fullName để tiện hiển thị
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
      // Đọc 'userId' hoặc 'id' từ JSON (giống UserModel)
      userId: json['userId'] ?? json['id'] ?? 0,
      // Đọc 'userName' hoặc 'username' (giống UserModel)
      userName: json['userName'] ?? json['username'] ?? '',
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
    if (fullName != null && fullName!.isNotEmpty) json['fullName'] = fullName;
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
  
  // ✅ Getter để lấy tên hiển thị (ưu tiên fullName từ User)
  String get displayName => fullName ?? userName;
  
  // ✅ Getter để tương thích với code cũ (username)
  String get username => userName;
}