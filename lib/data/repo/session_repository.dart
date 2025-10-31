// lib/data/repo/session_repository.dart

import '../../core/api_service/api_service.dart';
import '../model/session_model.dart';

class SessionRepository {
  // [SỬA 1] - Gọi 'instance' của ApiService, không tạo mới
  final ApiService _apiService = ApiService.instance;

  Future<Session> fetchSessionById(int sessionId) {
    return _apiService.getSessionById(sessionId);
  }

  /// Lấy lịch dạy theo giảng viên và ngày tháng (mặc định là hôm nay)
  Future<List<Session>> fetchSessionsByTeacherAndDate({
    required int teacherId,
    DateTime? date,
  }) {
    return _apiService.getSessionsByTeacherAndDate(
      teacherId: teacherId,
      date: date,
    );
  }

  // ✅ BỔ SUNG: Thêm phương thức này để lấy tất cả session cho một lớp
  /// Lấy tất cả các buổi học (quá khứ và hiện tại) CỦA MỘT LỚP HỌC
  Future<List<Session>> fetchSessionsBySectionId(int sectionId) {
    // (Bạn cũng cần thêm phương thức 'getSessionsBySectionId'
    // vào file api_service.dart của mình)
    return _apiService.getSessionsBySectionId(sectionId);
  }

  /// Cập nhật chỉ nội dung buổi học (khi ấn "Lưu" ở phần nội dung)
  Future<Session> updateSessionContent(int sessionId, String content) {
    return _apiService.updateSessionContent(sessionId, content);
  }

  /// Cập nhật toàn bộ buổi học (khi ấn nút "Lưu" cuối cùng)
  Future<Session> updateSessionComplete(Session session) {
    return _apiService.updateSessionComplete(session);
  }

  /// DEPRECATED: Sử dụng updateSessionContent hoặc updateSessionComplete thay thế
  @Deprecated('Sử dụng updateSessionContent cho cập nhật riêng lẻ hoặc updateSessionComplete cho cập nhật toàn bộ')
  Future<Session> updateSessionDetails(Session session) {
    // [SỬA 2] - Sửa lại cho khớp với chữ ký (signature)
    // của hàm 'updateSession' trong ApiService
    return _apiService.updateSession(session.sessionId!, session.toJson());
  }

  /// Lấy danh sách buổi học tương lai THEO GIẢNG VIÊN
  // ✅ SỬA: Sửa lại hàm này để yêu cầu teacherId
  Future<List<Session>> fetchFutureSessions({required int teacherId}) {
    return _apiService.getFutureSessionsByTeacher(teacherId);
  }

}