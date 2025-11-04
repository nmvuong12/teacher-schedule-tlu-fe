import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/api_service/session_manager.dart';
import '../../../data/model/user_model.dart';
import '../../../data/repo/teacher_repository.dart';
import '../../../data/model/teacher_dto.dart';

class TeacherData {
  final String name;
  final String title;
  final String department;
  final String specialty;
  final String phone;
  final String office;
  final String email;
  final List<String> subjects;
  final List<String> researchAreas;
  final String address;

  TeacherData({
    required this.name,
    required this.title,
    required this.department,
    required this.specialty,
    required this.phone,
    required this.office,
    required this.email,
    required this.subjects,
    required this.researchAreas,
    required this.address,
  });
}

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  final TeacherRepository _repo = TeacherRepository();
  late Future<TeacherData> futureTeacher;

  final TeacherData teacherMock = TeacherData(
    name: '',
    title: '',
    department: '',
    specialty: '',
    phone: '',
    office: '',
    email: '',
    subjects: const [],
    researchAreas: const [],
    address: '',
  );

  @override
  void initState() {
    super.initState();
    // Lấy teacherId từ session
    _loadTeacherFromSession();
  }

  Future<void> _loadTeacherFromSession() async {
    try {
      final (_, userJson) = await SessionManager.loadSession();
      if (userJson != null) {
        print('🔍 TeacherProfileScreen: Loading teacher from session');
        print('📦 Full userJson: $userJson');
        print('📦 teacherId in userJson: ${userJson['teacherId']}');
        print('📦 id in userJson: ${userJson['id']}');
        print('📦 username in userJson: ${userJson['username']}');
        
        final user = UserModel.fromJson(userJson);
        print('📦 UserModel parsed - id: ${user.id}, teacherId: ${user.teacherId}, username: ${user.username}');
        
        // Ưu tiên dùng teacherId, nếu null thì dùng id
        final teacherId = user.teacherId;
        final userId = user.id;
        
        print('📦 teacherId from session: $teacherId');
        print('📦 userId from session: $userId');
        print('📦 username from session: ${user.username}');
        
        // Ưu tiên lấy teacher theo username từ session (chắc chắn nhất)
        final username = user.username;
        if (username.isNotEmpty) {
          print('✅ Loading teacher profile for username: $username');
          futureTeacher = _loadTeacherByUsername(username);
          setState(() {});
        } else if (userId > 0) {
          print('⚠️ username is empty, trying to get teacher by userId: $userId');
          futureTeacher = _loadTeacherByUserId(userId);
          setState(() {});
        } else if (teacherId != null && teacherId > 0) {
          print('⚠️ userId is null, trying to get teacher by teacherId: $teacherId');
          futureTeacher = _loadTeacherWithFallback(teacherId, null);
          setState(() {});
        } else {
          print('⚠️ TeacherProfileScreen: No valid teacherId or userId found');
          futureTeacher = Future.value(teacherMock);
          setState(() {});
        }
      } else {
        print('⚠️ TeacherProfileScreen: No session found');
        futureTeacher = Future.value(teacherMock);
        setState(() {});
      }
    } catch (e) {
      print('❌ TeacherProfileScreen: Error loading session: $e');
      futureTeacher = Future.value(teacherMock);
      setState(() {});
    }
  }

  // Lấy teacher với fallback - thử theo primaryId (có thể là userId hoặc teacherId), nếu không khớp thì thử theo fallbackId
  Future<TeacherData> _loadTeacherWithFallback(int primaryId, int? fallbackId) async {
    try {
      print('🔍 TeacherProfileScreen._loadTeacherWithFallback: Requested primaryId=$primaryId, fallbackId=$fallbackId');
      
      // Lấy username từ session để verify
      final (_, userJson) = await SessionManager.loadSession();
      final sessionUsername = userJson?['username'] ?? '';
      print('🔍 Session username: $sessionUsername');
      
      // Thử lấy theo primaryId (có thể là userId hoặc teacherId)
      try {
        final TeacherDto dto = await _repo.getById(primaryId);
        
        print('✅ TeacherProfileScreen: Got data from API by primaryId=$primaryId');
        print('📦 teacherId: ${dto.teacherId}');
        print('📦 userId: ${dto.userId}');
        print('📦 userName: ${dto.userName}');
        print('📦 fullName: ${dto.fullName}');
        
        // Verify userName matches với username từ session
        if (sessionUsername.isNotEmpty) {
          print('🔍 Verifying userName - session: $sessionUsername, API: ${dto.userName}');
          if (dto.userName != sessionUsername) {
            print('❌ ERROR: userName mismatch - session: $sessionUsername, API: ${dto.userName}');
            // Thử fallback theo fallbackId
            if (fallbackId != null && fallbackId > 0) {
              print('🔄 Trying fallback: get teacher by fallbackId=$fallbackId');
              try {
                final fallbackDto = await _repo.getById(fallbackId);
                if (fallbackDto.userName == sessionUsername) {
                  print('✅ Fallback successful - userName matches!');
                  return _mapTeacherDtoToTeacherData(fallbackDto);
                }
              } catch (e) {
                print('⚠️ Fallback by fallbackId failed: $e');
              }
            }
            // Thử lấy theo userId nếu primaryId không phải userId
            if (dto.userId != primaryId && dto.userId > 0) {
              print('🔄 Trying fallback: get teacher by userId=${dto.userId}');
              try {
                final userIdDto = await _repo.getByUserId(dto.userId);
                if (userIdDto.userName == sessionUsername) {
                  print('✅ Fallback by userId successful - userName matches!');
                  return _mapTeacherDtoToTeacherData(userIdDto);
                }
              } catch (e) {
                print('⚠️ Fallback by userId failed: $e');
              }
            }
            // Nếu vẫn không khớp, thử lấy theo userId từ session
            if (userJson != null) {
              final sessionUserId = userJson['id'];
              if (sessionUserId != null && sessionUserId != primaryId) {
                print('🔄 Trying final fallback: get teacher by session userId=$sessionUserId');
                try {
                  final sessionUserIdDto = await _repo.getByUserId(sessionUserId);
                  if (sessionUserIdDto.userName == sessionUsername) {
                    print('✅ Final fallback successful - userName matches!');
                    return _mapTeacherDtoToTeacherData(sessionUserIdDto);
                  }
                } catch (e) {
                  print('⚠️ Final fallback failed: $e');
                }
              }
            }
            // Nếu vẫn không khớp, vẫn trả về dto hiện tại (nhưng log warning)
            print('⚠️ WARNING: Could not find matching teacher, using current result');
          } else {
            print('✅ userName matches session - correct teacher!');
          }
        }
        
        return _mapTeacherDtoToTeacherData(dto);
      } catch (e) {
        print('⚠️ Error loading by primaryId: $e');
        // Fallback: Thử theo fallbackId
        if (fallbackId != null && fallbackId > 0) {
          print('🔄 Fallback: Trying to get teacher by fallbackId=$fallbackId');
          try {
            return await _loadTeacherByUserId(fallbackId);
          } catch (e2) {
            print('⚠️ Fallback by fallbackId also failed: $e2');
          }
        }
        // Thử lấy theo userId từ session
        if (userJson != null) {
          final sessionUserId = userJson['id'];
          if (sessionUserId != null) {
            print('🔄 Fallback: Trying to get teacher by session userId=$sessionUserId');
            try {
              return await _loadTeacherByUserId(sessionUserId);
            } catch (e2) {
              print('⚠️ Fallback by session userId also failed: $e2');
            }
          }
        }
        rethrow;
      }
    } catch (e) {
      print('❌ Error in _loadTeacherWithFallback: $e');
      return teacherMock;
    }
  }

  // Map TeacherDto sang TeacherData
  TeacherData _mapTeacherDtoToTeacherData(TeacherDto dto) {
    print('📦 Mapping TeacherDto to TeacherData');
    print('📦 teacherId: ${dto.teacherId}');
    print('📦 userId: ${dto.userId}');
    print('📦 userName: ${dto.userName}');
    print('📦 fullName: ${dto.fullName}');
    print('📦 department: ${dto.department}');
    print('📦 phone: ${dto.phone}');
    print('📦 email: ${dto.email}');
    print('📦 office: ${dto.office}');
    print('📦 teachingSubjects: ${dto.teachingSubjects}');
    print('📦 researchFields: ${dto.researchFields}');
    print('📦 address: ${dto.address}');
      
    // Tạo title viết tắt (ví dụ: "Tiến sĩ" -> "TS")
    String degreeAbbr = 'GV';
    if (dto.degree != null && dto.degree!.isNotEmpty) {
      if (dto.degree!.toLowerCase().contains('tiến sĩ')) {
        degreeAbbr = 'TS';
      } else if (dto.degree!.toLowerCase().contains('thạc sĩ')) {
        degreeAbbr = 'ThS';
      } else if (dto.degree!.toLowerCase().contains('giáo sư')) {
        degreeAbbr = 'GS';
      } else if (dto.degree!.toLowerCase().contains('phó giáo sư')) {
        degreeAbbr = 'PGS';
      } else {
        degreeAbbr = dto.degree!;
      }
    }
    
    // Tạo thông tin cá nhân
    String personalInfo = '';
    if (dto.degree != null && dto.degree!.isNotEmpty) {
      personalInfo = 'Học vị: ${dto.degree}';
    }
    if (dto.specialization != null && dto.specialization!.isNotEmpty) {
      if (personalInfo.isNotEmpty) personalInfo += '\n';
      personalInfo += 'Chuyên môn: ${dto.specialization}';
    }
    if (personalInfo.isEmpty) {
      personalInfo = 'Tổng giờ dạy: ${dto.totalTeachingHours}';
    }
    
    return TeacherData(
      name: dto.fullName ?? dto.userName,
      title: degreeAbbr,
      department: dto.department,
      specialty: personalInfo,
      phone: dto.phone ?? '—',
      office: dto.office ?? '—',
      email: dto.email ?? '—',
      subjects: dto.parseSubjects(),
      researchAreas: dto.parseResearchAreas(),
      address: dto.address ?? '—',
    );
  }

  // Lấy teacher theo username (chắc chắn nhất)
  Future<TeacherData> _loadTeacherByUsername(String username) async {
    try {
      print('🔍 TeacherProfileScreen._loadTeacherByUsername: Requested username: $username');
      
      // Lấy tất cả teachers và filter theo username
      print('🔄 Getting all teachers and filtering by username=$username');
      final allTeachers = await _repo.getAll();
      print('📦 Found ${allTeachers.length} teachers total');
      
      // Log tất cả usernames để debug
      for (var t in allTeachers) {
        print('📦 Teacher: userId=${t.userId}, teacherId=${t.teacherId}, userName=${t.userName}');
      }
      
      final matchingTeacher = allTeachers.firstWhere(
        (t) => t.userName == username,
        orElse: () => throw Exception('Teacher not found for username: $username'),
      );
      
      print('✅ Found matching teacher: userId=${matchingTeacher.userId}, teacherId=${matchingTeacher.teacherId}, userName=${matchingTeacher.userName}');
      return _mapTeacherDtoToTeacherData(matchingTeacher);
    } catch (e) {
      print('❌ Error loading teacher by username: $e');
      // Fallback: Thử lấy theo userId từ session
      final (_, userJson) = await SessionManager.loadSession();
      if (userJson != null) {
        final userId = userJson['id'];
        if (userId != null && userId > 0) {
          print('🔄 Fallback: Trying to get teacher by userId=$userId');
          return await _loadTeacherByUserId(userId);
        }
      }
      return teacherMock;
    }
  }

  // Fallback: Lấy teacher theo userId
  Future<TeacherData> _loadTeacherByUserId(int userId) async {
    try {
      print('🔍 TeacherProfileScreen._loadTeacherByUserId: Requested userId=$userId');
      
      // Lấy username từ session để verify
      final (_, userJson) = await SessionManager.loadSession();
      final sessionUsername = userJson?['username'] ?? '';
      print('🔍 Session username: $sessionUsername');
      
      final TeacherDto dto = await _repo.getByUserId(userId);
      
      print('✅ TeacherProfileScreen: Got data from API by userId');
      print('📦 teacherId: ${dto.teacherId}');
      print('📦 userId: ${dto.userId}');
      print('📦 userName: ${dto.userName}');
      print('📦 fullName: ${dto.fullName}');
      
      // Verify userName matches với username từ session
      if (sessionUsername.isNotEmpty) {
        print('🔍 Verifying userName - session: $sessionUsername, API: ${dto.userName}');
        if (dto.userName != sessionUsername) {
          print('❌ ERROR: userName mismatch - session: $sessionUsername, API: ${dto.userName}');
          print('🔄 Trying to get all teachers and filter by session username...');
          
          // Fallback: Lấy tất cả teachers và filter theo session username
          try {
            final allTeachers = await _repo.getAll();
            final matchingTeacher = allTeachers.firstWhere(
              (t) => t.userName == sessionUsername,
              orElse: () => throw Exception('Teacher not found for username: $sessionUsername'),
            );
            print('✅ Found matching teacher by username: ${matchingTeacher.userName}');
            return _mapTeacherDtoToTeacherData(matchingTeacher);
          } catch (e) {
            print('⚠️ Could not find teacher by username: $e');
            // Vẫn trả về dto hiện tại nhưng log warning
            print('⚠️ WARNING: Returning teacher with mismatched userName');
          }
        } else {
          print('✅ userName matches session - correct teacher!');
        }
      }
      
      // Map tương tự như _loadTeacher
      String degreeAbbr = 'GV';
      if (dto.degree != null && dto.degree!.isNotEmpty) {
        if (dto.degree!.toLowerCase().contains('tiến sĩ')) {
          degreeAbbr = 'TS';
        } else if (dto.degree!.toLowerCase().contains('thạc sĩ')) {
          degreeAbbr = 'ThS';
        } else if (dto.degree!.toLowerCase().contains('giáo sư')) {
          degreeAbbr = 'GS';
        } else if (dto.degree!.toLowerCase().contains('phó giáo sư')) {
          degreeAbbr = 'PGS';
        } else {
          degreeAbbr = dto.degree!;
        }
      }
      
      String personalInfo = '';
      if (dto.degree != null && dto.degree!.isNotEmpty) {
        personalInfo = 'Học vị: ${dto.degree}';
      }
      if (dto.specialization != null && dto.specialization!.isNotEmpty) {
        if (personalInfo.isNotEmpty) personalInfo += '\n';
        personalInfo += 'Chuyên môn: ${dto.specialization}';
      }
      if (personalInfo.isEmpty) {
        personalInfo = 'Tổng giờ dạy: ${dto.totalTeachingHours}';
      }
      
      return TeacherData(
        name: dto.fullName ?? dto.userName,
        title: degreeAbbr,
        department: dto.department,
        specialty: personalInfo,
        phone: dto.phone ?? '—',
        office: dto.office ?? '—',
        email: dto.email ?? '—',
        subjects: dto.parseSubjects(),
        researchAreas: dto.parseResearchAreas(),
        address: dto.address ?? '—',
      );
    } catch (e) {
      print('❌ Error loading teacher by userId: $e');
      return teacherMock;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TeacherData>(
      future: futureTeacher,
      builder: (context, snapshot) {
        final teacher = snapshot.data ?? teacherMock;
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/anhdaidien.jpg',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.blueGrey,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      teacher.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${teacher.title}. - ${teacher.department}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              _buildInfoItem(
                icon: Icons.person_outline,
                title: 'Thông tin cá nhân',
                content: teacher.specialty,
              ),
              _buildInfoItem(
                icon: Icons.call_outlined,
                title: 'Liên hệ',
                content: 'Điện thoại: ${teacher.phone}\nVăn phòng: ${teacher.office}',
              ),
              _buildInfoItem(
                icon: Icons.email_outlined,
                title: 'Email',
                content: teacher.email,
              ),
              _buildListInfoItem(
                icon: FontAwesomeIcons.bookOpen,
                title: 'Môn giảng dạy',
                contentList: teacher.subjects,
              ),
              _buildListInfoItem(
                icon: FontAwesomeIcons.bookBookmark,
                title: 'Lĩnh vực nghiên cứu',
                contentList: teacher.researchAreas,
              ),
              _buildInfoItem(
                icon: Icons.location_on_outlined,
                title: 'Địa chỉ',
                content: teacher.address,
                showDivider: false,
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String content,
    bool showDivider = true,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF3B5998)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
            if (showDivider) const Divider(height: 20),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListInfoItem({
    required IconData icon,
    required String title,
    required List<String> contentList,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF3B5998), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            if (contentList.isEmpty)
              const Text(
                'Chưa cập nhật',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              )
            else
              ...contentList.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}