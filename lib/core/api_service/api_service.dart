// [api_service.dart] - ĐÃ SỬA LỖI VÀ BỔ SUNG CÁC HÀM API CÒN THIẾU
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

// Import tất cả model của bạn
import '../../data/model/attendance_model.dart';
import '../../data/model/session_model.dart'; // <- File Session TỐT
import '../../data/model/user_model.dart';

// [SỬA LỖI] Ẩn 'Session' từ file 'models.dart' để tránh xung đột
import '../../data/model/models.dart' hide Session;

import 'session_manager.dart';

class ApiService {
  final Dio _dio = Dio();

  // [SỬA 1] - Chuyển thành Singleton
  static final ApiService instance = ApiService._();

  // [SỬA 2] - Constructor riêng tư
  ApiService._() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 8);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionManager.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            debugPrint("Token đã hết hạn hoặc không hợp lệ.");
          }
          return handler.next(e);
        },
      ),
    );
  }

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8080/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://127.0.0.1:8080/api';
  }

  // --- CÁC HÀM AUTH ---
  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        queryParameters: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final user = UserModel.fromJson(response.data);
        final String fakeToken = base64Encode(utf8.encode('${user.username}:${user.role}:${DateTime.now().millisecondsSinceEpoch}'));
        await SessionManager.saveSession(token: fakeToken, user: user);

        return LoginResponse(
          success: true,
          message: 'Đăng nhập thành công',
          user: user,
          token: fakeToken,
        );
      }

      return LoginResponse(success: false, message: 'Server trả về lỗi: ${response.statusCode}');

    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return LoginResponse(success: false, message: 'Tài khoản hoặc mật khẩu không chính xác');
      }
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.connectionError) {
        return LoginResponse(success: false, message: 'Không thể kết nối tới server.');
      }
      return LoginResponse(success: false, message: 'Lỗi không xác định: ${e.message}');
    }
  }

  Future<UserModel?> getUserProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return UserModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Lỗi khi lấy profile: $e');
      return null;
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      return (response.data as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách user: $e');
      return [];
    }
  }

  // --- CÁC HÀM ATTENDANCE ---
  Future<List<Attendance>> getAttendancesForSession(int sessionId) async {
    try {
      final response = await _dio.get(
        '/attendances',
        queryParameters: {'sessionId': sessionId},
      );
      return (response.data as List)
          .map((json) => Attendance.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối tới server.');
      }
      throw Exception('Không thể tải danh sách điểm danh: ${e.message}');
    }
  }

  Future<Attendance> updateAttendance(Attendance attendance) async {
    try {
      final response = await _dio.put(
        '/attendances/${attendance.sessionId}/${attendance.studentId}',
        data: attendance.toJson(),
      );
      return Attendance.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Cập nhật điểm danh thất bại: ${e.message}');
      }
      throw Exception('Cập nhật điểm danh thất bại: ${e.message}');
    }
  }

  // --- CÁC HÀM SESSION ---
  Future<Session> updateSessionContent(int sessionId, String content) async {
    try {
      final Map<String, dynamic> requestData = {
        'content': content.trim(),
        'label': null,
        'status': null
      };
      final response = await _dio.patch(
        '/sessions/$sessionId/content',
        data: requestData,
        options: Options(
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        ),
      );
      return Session.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối tới server.');
      }
      throw Exception('Cập nhật nội dung buổi học thất bại: ${e.message}');
    }
  }

  Future<Session> getSessionById(int sessionId) async {
    try {
      final response = await _dio.get('/sessions/$sessionId');
      return Session.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối tới server.');
      }
      throw Exception('Không thể tải thông tin buổi học: ${e.message}');
    }
  }

  Future<Session> updateSessionComplete(Session session) async {
    try {
      final requestData = session.toJson();
      final response = await _dio.put(
        '/sessions/${session.sessionId}',
        data: requestData,
        options: Options(
          headers: { 'Content-Type': 'application/json; charset=utf-8' },
        ),
      );
      return Session.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối tới server.');
      }
      throw Exception('Lưu toàn bộ buổi học thất bại: ${e.message}');
    }
  }

  @Deprecated('Sử dụng updateSessionContent hoặc updateSessionComplete')
  Future<Session> updateSession(int id, Map<String, dynamic> data) async {
    // Hàm này được AppController gọi, nên giữ nguyên triển khai
    try {
      final response = await _dio.put('/sessions/$id', data: data);
      return Session.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật session (deprecated): $e');
      throw Exception('Không thể cập nhật session: ${e.message}');
    }
  }

  Future<List<Session>> getSessionsByTeacherAndDate({
    required int teacherId,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);
      final response = await _dio.get(
        '/sessions/teacher/$teacherId/date/$dateStr',
      );
      final allSessions = (response.data as List)
          .map((json) => Session.fromJson(json))
          .toList();
      allSessions.sort((a, b) => a.date.compareTo(b.date));
      return allSessions;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy lịch dạy cho giảng viên này.');
      }
      throw Exception('Không thể tải lịch dạy: ${e.message}');
    }
  }

  Future<List<Session>> getFutureSessionsByTeacher(int teacherId) async {
    try {
      debugPrint("🔍 Fetching future sessions for teacher $teacherId");
      final response = await _dio.get(
        '/sessions',
        queryParameters: {'teacherId': teacherId},
      );
      final allSessions = (response.data as List)
          .map((json) => Session.fromJson(json))
          .toList();
      allSessions.sort((a, b) => a.date.compareTo(b.date));
      debugPrint("✅ Found ${allSessions.length} future sessions for teacher $teacherId");
      return allSessions;
    } on DioException catch (e) {
      debugPrint("API Error - getFutureSessionsByTeacher: ${e.message}");
      throw Exception('Không thể tải lịch học tương lai: ${e.message}');
    }
  }

  Future<List<Session>> getSessionsBySectionId(int sectionId) async {
    try {
      final response = await _dio.get('/sessions/course-section/$sectionId/all');
      final allSessions = (response.data as List)
          .map((json) => Session.fromJson(json))
          .toList();
      allSessions.sort((a, b) => a.date.compareTo(b.date));
      return allSessions;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy buổi học nào cho lớp này.');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối tới server.');
      }
      throw Exception('Không thể tải danh sách buổi học: ${e.message}');
    }
  }

  Future<bool> testSessionUpdate(int sessionId) async {
    try {
      await _dio.get('/sessions/$sessionId');
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- CÁC HÀM TEACHER ---
  Future<List<Teacher>> getTeachers() async {
    try {
      final response = await _dio.get('/teachers');
      return (response.data as List)
          .map((json) => Teacher.fromJson(json))
          .toList();
    } on DioException catch (e) {
      debugPrint('Lỗi khi lấy danh sách giảng viên: $e');
      throw Exception('Không thể tải danh sách giảng viên: ${e.message}');
    }
  }

  Future<Teacher> createTeacher(Teacher teacher) async {
    try {
      final response = await _dio.post(
        '/teachers',
        data: teacher.toJson(),
      );
      return Teacher.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo giảng viên: $e');
      throw Exception('Không thể tạo giảng viên: ${e.message}');
    }
  }

  Future<Teacher> updateTeacher(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/teachers/$id',
        data: data,
      );
      return Teacher.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật giảng viên: $e');
      throw Exception('Không thể cập nhật giảng viên: ${e.message}');
    }
  }

  Future<void> deleteTeacher(int teacherId) async {
    try {
      await _dio.delete('/teachers/$teacherId');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa giảng viên: $e');
      throw Exception('Không thể xóa giảng viên: ${e.message}');
    }
  }

  Future<List<Teacher>> searchTeachers(String keyword) async {
    try {
      final response = await _dio.get(
        '/teachers/search',
        queryParameters: {'keyword': keyword},
      );
      return (response.data as List)
          .map((json) => Teacher.fromJson(json))
          .toList();
    } on DioException catch (e) {
      debugPrint('Lỗi khi tìm kiếm giảng viên: $e');
      throw Exception('Không thể tìm kiếm giảng viên: ${e.message}');
    }
  }

  // --- [PHẦN ĐÃ SỬA] - TRIỂN KHAI CÁC HÀM CÒN THIẾU ---

  // --- CourseSection ---
  Future<List<dynamic>> getCourseSections() async {
    try {
      final response = await _dio.get('/course-sections');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint('Lỗi khi lấy danh sách học phần: $e');
      throw Exception('Không thể tải danh sách học phần: ${e.message}');
    }
  }

  Future<dynamic> createCourseSection(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/course-sections', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo học phần: $e');
      throw Exception('Không thể tạo học phần: ${e.message}');
    }
  }

  Future<dynamic> updateCourseSection(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/course-sections/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật học phần: $e');
      throw Exception('Không thể cập nhật học phần: ${e.message}');
    }
  }

  Future<void> deleteCourseSection(int id) async {
    try {
      await _dio.delete('/course-sections/$id');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa học phần: $e');
      throw Exception('Không thể xóa học phần: ${e.message}');
    }
  }

  // --- TeachingLeave ---
  Future<List<dynamic>> getTeachingLeaves() async {
    try {
      final response = await _dio.get('/teaching-leaves');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint('Lỗi khi lấy danh sách đơn nghỉ: $e');
      throw Exception('Không thể tải danh sách đơn nghỉ: ${e.message}');
    }
  }

  Future<dynamic> updateTeachingLeave(int id, Map<String, dynamic> data) async {
    try {
      // AppController gọi hàm này với sessionId làm id
      final response = await _dio.put('/teaching-leaves/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật đơn nghỉ: $e');
      throw Exception('Không thể cập nhật đơn nghỉ: ${e.message}');
    }
  }

  Future<void> deleteTeachingLeave(int id) async {
    try {
      // AppController gọi hàm này với sessionId làm id
      await _dio.delete('/teaching-leaves/$id');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa đơn nghỉ: $e');
      throw Exception('Không thể xóa đơn nghỉ: ${e.message}');
    }
  }

  // --- Session (CRUD chính) ---
  Future<List<dynamic>> getSessions() async {
    try {
      final response = await _dio.get('/sessions');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint('Lỗi khi lấy danh sách buổi học: $e');
      throw Exception('Không thể tải danh sách buổi học: ${e.message}');
    }
  }

  Future<dynamic> createSession(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/sessions', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo buổi học: $e');
      throw Exception('Không thể tạo buổi học: ${e.message}');
    }
  }

  Future<void> deleteSession(int id) async {
    try {
      await _dio.delete('/sessions/$id');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa buổi học: $e');
      throw Exception('Không thể xóa buổi học: ${e.message}');
    }
  }

  // --- Subject ---
  Future<List<dynamic>> getSubjects() async {
    try {
      final response = await _dio.get('/subjects');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint('Lỗi khi lấy danh sách môn học: $e');
      throw Exception('Không thể tải danh sách môn học: ${e.message}');
    }
  }

  Future<dynamic> createSubject(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/subjects', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo môn học: $e');
      throw Exception('Không thể tạo môn học: ${e.message}');
    }
  }

  Future<dynamic> updateSubject(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/subjects/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật môn học: $e');
      throw Exception('Không thể cập nhật môn học: ${e.message}');
    }
  }

  Future<void> deleteSubject(int id) async {
    try {
      await _dio.delete('/subjects/$id');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa môn học: $e');
      throw Exception('Không thể xóa môn học: ${e.message}');
    }
  }

  // --- SchoolClass (Lớp học) ---
  Future<List<dynamic>> getClasses() async {
    try {
      // Giả sử endpoint là '/classes'
      final response = await _dio.get('/classes');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint('Lỗi khi lấy danh sách lớp học: $e');
      throw Exception('Không thể tải danh sách lớp học: ${e.message}');
    }
  }

  Future<dynamic> createClass(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/classes', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo lớp học: $e');
      throw Exception('Không thể tạo lớp học: ${e.message}');
    }
  }

  Future<dynamic> updateClass(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/classes/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật lớp học: $e');
      throw Exception('Không thể cập nhật lớp học: ${e.message}');
    }
  }

  Future<void> deleteClass(int id) async {
    try {
      await _dio.delete('/classes/$id');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa lớp học: $e');
      throw Exception('Không thể xóa lớp học: ${e.message}');
    }
  }

  // --- Student ---
  Future<List<dynamic>> getStudents() async {
    try {
      final response = await _dio.get('/students');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint('Lỗi khi lấy danh sách sinh viên: $e');
      throw Exception('Không thể tải danh sách sinh viên: ${e.message}');
    }
  }

  Future<dynamic> createStudent(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/students', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo sinh viên: $e');
      throw Exception('Không thể tạo sinh viên: ${e.message}');
    }
  }

  Future<dynamic> updateStudent(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/students/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật sinh viên: $e');
      throw Exception('Không thể cập nhật sinh viên: ${e.message}');
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      await _dio.delete('/students/$id');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa sinh viên: $e');
      throw Exception('Không thể xóa sinh viên: ${e.message}');
    }
  }

  // --- User ---
  Future<dynamic> createUser(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/users', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo người dùng: $e');
      throw Exception('Không thể tạo người dùng: ${e.message}');
    }
  }

  Future<dynamic> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/users/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật người dùng: $e');
      throw Exception('Không thể cập nhật người dùng: ${e.message}');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('/users/$id');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa người dùng: $e');
      throw Exception('Không thể xóa người dùng: ${e.message}');
    }
  }
}// [api_service.dart] - ĐÃ SỬA LỖI VÀ BỔ SUNG CÁC HÀM API CÒN THIẾU
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

// Import tất cả model của bạn
import '../../data/model/attendance_model.dart';
import '../../data/model/session_model.dart'; // <- File Session TỐT
import '../../data/model/user_model.dart';

// [SỬA LỖI] Ẩn 'Session' từ file 'models.dart' để tránh xung đột
import '../../data/model/models.dart' hide Session;

import 'session_manager.dart';

class ApiService {
  final Dio _dio = Dio();

  // [SỬA 1] - Chuyển thành Singleton
  static final ApiService instance = ApiService._();

  // [SỬA 2] - Constructor riêng tư
  ApiService._() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 8);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionManager.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            debugPrint("Token đã hết hạn hoặc không hợp lệ.");
          }
          return handler.next(e);
        },
      ),
    );
  }

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8080/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://127.0.0.1:8080/api';
  }

  // --- CÁC HÀM AUTH ---
  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        queryParameters: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final user = UserModel.fromJson(response.data);
        final String fakeToken = base64Encode(utf8.encode('${user.username}:${user.role}:${DateTime.now().millisecondsSinceEpoch}'));
        await SessionManager.saveSession(token: fakeToken, user: user);

        return LoginResponse(
          success: true,
          message: 'Đăng nhập thành công',
          user: user,
          token: fakeToken,
        );
      }

      return LoginResponse(success: false, message: 'Server trả về lỗi: ${response.statusCode}');

    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return LoginResponse(success: false, message: 'Tài khoản hoặc mật khẩu không chính xác');
      }
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.connectionError) {
        return LoginResponse(success: false, message: 'Không thể kết nối tới server.');
      }
      return LoginResponse(success: false, message: 'Lỗi không xác định: ${e.message}');
    }
  }

  Future<UserModel?> getUserProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return UserModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Lỗi khi lấy profile: $e');
      return null;
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      return (response.data as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách user: $e');
      return [];
    }
  }

  // --- CÁC HÀM ATTENDANCE ---
  Future<List<Attendance>> getAttendancesForSession(int sessionId) async {
    try {
      final response = await _dio.get(
        '/attendances',
        queryParameters: {'sessionId': sessionId},
      );
      return (response.data as List)
          .map((json) => Attendance.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối tới server.');
      }
      throw Exception('Không thể tải danh sách điểm danh: ${e.message}');
    }
  }

  Future<Attendance> updateAttendance(Attendance attendance) async {
    try {
      final response = await _dio.put(
        '/attendances/${attendance.sessionId}/${attendance.studentId}',
        data: attendance.toJson(),
      );
      return Attendance.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Cập nhật điểm danh thất bại: ${e.message}');
      }
      throw Exception('Cập nhật điểm danh thất bại: ${e.message}');
    }
  }

  // --- CÁC HÀM SESSION ---
  Future<Session> updateSessionContent(int sessionId, String content) async {
    try {
      final Map<String, dynamic> requestData = {
        'content': content.trim(),
        'label': null,
        'status': null
      };
      final response = await _dio.patch(
        '/sessions/$sessionId/content',
        data: requestData,
        options: Options(
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        ),
      );
      return Session.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối tới server.');
      }
      throw Exception('Cập nhật nội dung buổi học thất bại: ${e.message}');
    }
  }

  Future<Session> getSessionById(int sessionId) async {
    try {
      final response = await _dio.get('/sessions/$sessionId');
      return Session.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối tới server.');
      }
      throw Exception('Không thể tải thông tin buổi học: ${e.message}');
    }
  }

  Future<Session> updateSessionComplete(Session session) async {
    try {
      final requestData = session.toJson();
      final response = await _dio.put(
        '/sessions/${session.sessionId}',
        data: requestData,
        options: Options(
          headers: { 'Content-Type': 'application/json; charset=utf-8' },
        ),
      );
      return Session.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối tới server.');
      }
      throw Exception('Lưu toàn bộ buổi học thất bại: ${e.message}');
    }
  }

  @Deprecated('Sử dụng updateSessionContent hoặc updateSessionComplete')
  Future<Session> updateSession(int id, Map<String, dynamic> data) async {
    // Hàm này được AppController gọi, nên giữ nguyên triển khai
    try {
      final response = await _dio.put('/sessions/$id', data: data);
      return Session.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật session (deprecated): $e');
      throw Exception('Không thể cập nhật session: ${e.message}');
    }
  }

  Future<List<Session>> getSessionsByTeacherAndDate({
    required int teacherId,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);
      final response = await _dio.get(
        '/sessions/teacher/$teacherId/date/$dateStr',
      );
      final allSessions = (response.data as List)
          .map((json) => Session.fromJson(json))
          .toList();
      allSessions.sort((a, b) => a.date.compareTo(b.date));
      return allSessions;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy lịch dạy cho giảng viên này.');
      }
      throw Exception('Không thể tải lịch dạy: ${e.message}');
    }
  }

  Future<List<Session>> getFutureSessionsByTeacher(int teacherId) async {
    try {
      debugPrint("🔍 Fetching future sessions for teacher $teacherId");
      final response = await _dio.get(
        '/sessions',
        queryParameters: {'teacherId': teacherId},
      );
      final allSessions = (response.data as List)
          .map((json) => Session.fromJson(json))
          .toList();
      allSessions.sort((a, b) => a.date.compareTo(b.date));
      debugPrint("✅ Found ${allSessions.length} future sessions for teacher $teacherId");
      return allSessions;
    } on DioException catch (e) {
      debugPrint("API Error - getFutureSessionsByTeacher: ${e.message}");
      throw Exception('Không thể tải lịch học tương lai: ${e.message}');
    }
  }

  Future<List<Session>> getSessionsBySectionId(int sectionId) async {
    try {
      final response = await _dio.get('/sessions/course-section/$sectionId/all');
      final allSessions = (response.data as List)
          .map((json) => Session.fromJson(json))
          .toList();
      allSessions.sort((a, b) => a.date.compareTo(b.date));
      return allSessions;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy buổi học nào cho lớp này.');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Không thể kết nối tới server.');
      }
      throw Exception('Không thể tải danh sách buổi học: ${e.message}');
    }
  }

  Future<bool> testSessionUpdate(int sessionId) async {
    try {
      await _dio.get('/sessions/$sessionId');
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- CÁC HÀM TEACHER ---
  Future<List<Teacher>> getTeachers() async {
    try {
      final response = await _dio.get('/teachers');
      return (response.data as List)
          .map((json) => Teacher.fromJson(json))
          .toList();
    } on DioException catch (e) {
      debugPrint('Lỗi khi lấy danh sách giảng viên: $e');
      throw Exception('Không thể tải danh sách giảng viên: ${e.message}');
    }
  }

  Future<Teacher> createTeacher(Teacher teacher) async {
    try {
      final response = await _dio.post(
        '/teachers',
        data: teacher.toJson(),
      );
      return Teacher.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo giảng viên: $e');
      throw Exception('Không thể tạo giảng viên: ${e.message}');
    }
  }

  Future<Teacher> updateTeacher(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/teachers/$id',
        data: data,
      );
      return Teacher.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật giảng viên: $e');
      throw Exception('Không thể cập nhật giảng viên: ${e.message}');
    }
  }

  Future<void> deleteTeacher(int teacherId) async {
    try {
      await _dio.delete('/teachers/$teacherId');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa giảng viên: $e');
      throw Exception('Không thể xóa giảng viên: ${e.message}');
    }
  }

  Future<List<Teacher>> searchTeachers(String keyword) async {
    try {
      final response = await _dio.get(
        '/teachers/search',
        queryParameters: {'keyword': keyword},
      );
      return (response.data as List)
          .map((json) => Teacher.fromJson(json))
          .toList();
    } on DioException catch (e) {
      debugPrint('Lỗi khi tìm kiếm giảng viên: $e');
      throw Exception('Không thể tìm kiếm giảng viên: ${e.message}');
    }
  }

  // --- [PHẦN ĐÃ SỬA] - TRIỂN KHAI CÁC HÀM CÒN THIẾU ---

  // --- CourseSection ---
  Future<List<dynamic>> getCourseSections() async {
    try {
      final response = await _dio.get('/course-sections');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint('Lỗi khi lấy danh sách học phần: $e');
      throw Exception('Không thể tải danh sách học phần: ${e.message}');
    }
  }

  Future<dynamic> createCourseSection(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/course-sections', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo học phần: $e');
      throw Exception('Không thể tạo học phần: ${e.message}');
    }
  }

  Future<dynamic> updateCourseSection(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/course-sections/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật học phần: $e');
      throw Exception('Không thể cập nhật học phần: ${e.message}');
    }
  }

  Future<void> deleteCourseSection(int id) async {
    try {
      await _dio.delete('/course-sections/$id');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa học phần: $e');
      throw Exception('Không thể xóa học phần: ${e.message}');
    }
  }

  // --- TeachingLeave ---
  Future<List<dynamic>> getTeachingLeaves() async {
    try {
      final response = await _dio.get('/teaching-leaves');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint('Lỗi khi lấy danh sách đơn nghỉ: $e');
      throw Exception('Không thể tải danh sách đơn nghỉ: ${e.message}');
    }
  }

  Future<dynamic> updateTeachingLeave(int id, Map<String, dynamic> data) async {
    try {
      // AppController gọi hàm này với sessionId làm id
      final response = await _dio.put('/teaching-leaves/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật đơn nghỉ: $e');
      throw Exception('Không thể cập nhật đơn nghỉ: ${e.message}');
    }
  }

  Future<void> deleteTeachingLeave(int id) async {
    try {
      // AppController gọi hàm này với sessionId làm id
      await _dio.delete('/teaching-leaves/$id');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa đơn nghỉ: $e');
      throw Exception('Không thể xóa đơn nghỉ: ${e.message}');
    }
  }

  // --- Session (CRUD chính) ---
  Future<List<dynamic>> getSessions() async {
    try {
      final response = await _dio.get('/sessions');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint('Lỗi khi lấy danh sách buổi học: $e');
      throw Exception('Không thể tải danh sách buổi học: ${e.message}');
    }
  }

  Future<dynamic> createSession(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/sessions', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo buổi học: $e');
      throw Exception('Không thể tạo buổi học: ${e.message}');
    }
  }

  Future<void> deleteSession(int id) async {
    try {
      await _dio.delete('/sessions/$id');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa buổi học: $e');
      throw Exception('Không thể xóa buổi học: ${e.message}');
    }
  }

  // --- Subject ---
  Future<List<dynamic>> getSubjects() async {
    try {
      final response = await _dio.get('/subjects');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint('Lỗi khi lấy danh sách môn học: $e');
      throw Exception('Không thể tải danh sách môn học: ${e.message}');
    }
  }

  Future<dynamic> createSubject(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/subjects', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo môn học: $e');
      throw Exception('Không thể tạo môn học: ${e.message}');
    }
  }

  Future<dynamic> updateSubject(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/subjects/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật môn học: $e');
      throw Exception('Không thể cập nhật môn học: ${e.message}');
    }
  }

  Future<void> deleteSubject(int id) async {
    try {
      await _dio.delete('/subjects/$id');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa môn học: $e');
      throw Exception('Không thể xóa môn học: ${e.message}');
    }
  }

  // --- SchoolClass (Lớp học) ---
  Future<List<dynamic>> getClasses() async {
    try {
      // Giả sử endpoint là '/classes'
      final response = await _dio.get('/classes');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint('Lỗi khi lấy danh sách lớp học: $e');
      throw Exception('Không thể tải danh sách lớp học: ${e.message}');
    }
  }

  Future<dynamic> createClass(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/classes', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo lớp học: $e');
      throw Exception('Không thể tạo lớp học: ${e.message}');
    }
  }

  Future<dynamic> updateClass(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/classes/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật lớp học: $e');
      throw Exception('Không thể cập nhật lớp học: ${e.message}');
    }
  }

  Future<void> deleteClass(int id) async {
    try {
      await _dio.delete('/classes/$id');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa lớp học: $e');
      throw Exception('Không thể xóa lớp học: ${e.message}');
    }
  }

  // --- Student ---
  Future<List<dynamic>> getStudents() async {
    try {
      final response = await _dio.get('/students');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint('Lỗi khi lấy danh sách sinh viên: $e');
      throw Exception('Không thể tải danh sách sinh viên: ${e.message}');
    }
  }

  Future<dynamic> createStudent(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/students', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo sinh viên: $e');
      throw Exception('Không thể tạo sinh viên: ${e.message}');
    }
  }

  Future<dynamic> updateStudent(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/students/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật sinh viên: $e');
      throw Exception('Không thể cập nhật sinh viên: ${e.message}');
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      await _dio.delete('/students/$id');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa sinh viên: $e');
      throw Exception('Không thể xóa sinh viên: ${e.message}');
    }
  }

  // --- User ---
  Future<dynamic> createUser(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/users', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo người dùng: $e');
      throw Exception('Không thể tạo người dùng: ${e.message}');
    }
  }

  Future<dynamic> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/users/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      debugPrint('Lỗi khi cập nhật người dùng: $e');
      throw Exception('Không thể cập nhật người dùng: ${e.message}');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('/users/$id');
    } on DioException catch (e) {
      debugPrint('Lỗi khi xóa người dùng: $e');
      throw Exception('Không thể xóa người dùng: ${e.message}');
    }
  }
}