// lib/data/repo/attendance_repository.dart

import '../../core/api_service/api_service.dart';
import '../model/attendance_model.dart';
import '../model/attendance_dto.dart';

class AttendanceRepository {
  // [SỬA] - Gọi 'instance' của ApiService, không tạo mới
  final ApiService _apiService = ApiService.instance;

  /// Lấy danh sách điểm danh (sinh viên) của một buổi học
  Future<List<Attendance>> fetchAttendancesForSession(int sessionId) {
    return _apiService.getAttendancesForSession(sessionId);
  }

  /// Cập nhật trạng thái điểm danh của 1 sinh viên
  Future<Attendance> updateAttendance(Attendance attendance) {
    return _apiService.updateAttendance(attendance);
  }

  /// Lấy danh sách điểm danh đơn giản của một student trong một course section.
  /// Chỉ trả về status, date và label.
  Future<List<AttendanceDto>> fetchAttendanceListByStudentAndSection(
      int studentId, int sectionId) async {
    final data = await _apiService.getAttendanceListByStudentAndSection(
        studentId, sectionId);
    return data.map((json) => AttendanceDto.fromJson(json)).toList();
  }
}