import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/model/user_model.dart';
import '../../../data/model/session_model.dart';
import '../../../data/repo/session_repository.dart';
import 'attendence_screen.dart';
import 'content_detail_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  final UserModel user;
  const TeacherHomeScreen({super.key, required this.user});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final SessionRepository _sessionRepository = SessionRepository();
  late Future<List<Session>> _sessionsFuture;

  // ✅ 1. LƯU DANH SÁCH VÀO BIẾN STATE
  List<Session> _sessionsList = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    if (widget.user.teacherId != null) {
      setState(() {
        _sessionsFuture = _sessionRepository.fetchSessionsByTeacherAndDate(
          teacherId: widget.user.teacherId!,
        );
      });
    } else {
      setState(() {
        _sessionsFuture = Future.error("Tài khoản giáo viên không hợp lệ (thiếu teacherId).");
      });
    }
  }

  Future<void> _refreshSessions() async {
    _loadSessions();
  }

  // ✅ 2. SỬA HÀM NÀY ĐỂ CẬP NHẬT MỘT MỤC
  void _handleScreenPop(dynamic result) {
    // Kiểm tra xem kết quả trả về có phải là một Session object không
    if (result is Session) {
      // Nếu đúng, cập nhật danh sách mà không cần gọi lại API
      setState(() {
        // Tìm vị trí của buổi học cũ trong danh sách
        final index = _sessionsList.indexWhere((s) => s.sessionId == result.sessionId);
        if (index != -1) {
          // Thay thế nó bằng buổi học đã được cập nhật
          _sessionsList[index] = result;
        }
      });
    } else if (result == true) {
      // Nếu chỉ nhận 'true', reload lại toàn bộ (phương án dự phòng)
      _refreshSessions();
    }
    // Nếu 'false' hoặc 'null' (từ nút 'Quay lại'), không làm gì cả
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Session>>(
      future: _sessionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Vẫn hiển thị loading khi tải lần đầu
          if (_sessionsList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          // Nhưng nếu đang refresh, giữ lại dữ liệu cũ
          return _buildListView();
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Lỗi tải dữ liệu: ${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: RefreshIndicator(
              onRefresh: _refreshSessions,
              child: ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text("Không có lịch học nào hôm nay.")),
                ],
              ),
            ),
          );
        }

        // ✅ 3. GÁN DỮ LIỆU TỪ SNAPSHOT VÀO BIẾN STATE
        _sessionsList = snapshot.data!;

        // ✅ 4. GỌI WIDGET LISTVIEW TÁCH BIỆT
        return _buildListView();
      },
    );
  }

  // ✅ 5. TÁCH LISTVIEW RA HÀM RIÊNG
  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: _refreshSessions,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Lịch trình hôm nay (${_sessionsList.length} buổi học)",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          // Dùng `_sessionsList` thay vì `sessionsList` từ snapshot
          ..._sessionsList.map((session) => ExpandableClassCard(
            session: session,
            onNavigateBack: _handleScreenPop,
          )).toList(),
        ],
      ),
    );
  }
}

// --- Widget Card Buổi Học ---
class ExpandableClassCard extends StatelessWidget {
  final Session session;
  final Function(dynamic result) onNavigateBack;

  const ExpandableClassCard({
    super.key,
    required this.session,
    required this.onNavigateBack,
  });

  @override
  Widget build(BuildContext context) {
    // SỬA: Lấy thông tin trạng thái từ model
    final statusInfo = session.getStatusInfo();
    final statusText = statusInfo['text'] as String;
    final statusColor = statusInfo['color'] as Color;

    final formattedDate = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(session.date);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        // ✅ Thêm key này để Flutter biết mục nào đã thay đổi
        key: ValueKey(session.sessionId),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // SỬA: Hiển thị subjectName thay vì label
        title: Text(session.subjectName ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "$formattedDate | ${session.timeRange}",
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(height: 16),

          // ✅✅✅ DÒNG ĐÃ THÊM ✅✅✅
          // Hiển thị tên lớp (className)
          _buildDetailRow(Icons.class_outlined, "Lớp:", session.className ?? 'N/A'),

          _buildDetailRow(Icons.meeting_room, "Phòng học:", session.classroom),

          // ✅ Hiển thị trạng thái với màu
          _buildDetailRow(Icons.info_outline, "Trạng thái:", statusText, valueColor: statusColor),

          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionButton(context, "Nội dung", Icons.edit_document, Colors.blue.shade700),
              const SizedBox(width: 8),
              _buildActionButton(context, "Điểm danh", Icons.checklist, Colors.green.shade700),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text("$label ", style: TextStyle(color: Colors.grey.shade700)),
          Expanded(
            child: Text(
              value,
              // ✅ Sử dụng valueColor
              style: TextStyle(fontWeight: FontWeight.w600, color: valueColor ?? Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, IconData icon, Color color) {
    VoidCallback? onPressed;

    // ✅ SỬA: Lấy cả className để truyền đi
    final String courseTitle = session.subjectName ?? 'N/A';
    final String classInfo = '${session.className ?? 'Lớp N/A'} - Phòng: ${session.classroom}'; // vd: "64KTPM3 - Phòng: D202"

    if (text == "Nội dung") {
      onPressed = () async {
        // ✅ CHỜ KẾT QUẢ TRẢ VỀ TỪ MÀN HÌNH CON
        final result = await Navigator.push(context, MaterialPageRoute(
            builder: (context) => ContentDetailScreen(sessionId: session.sessionId!)));
        // ✅ GỬI KẾT QUẢ (CÓ THỂ LÀ `Session` MỚI) CHO HÀM CALLBACK
        onNavigateBack(result);
      };
    } else if (text == "Điểm danh") {
      onPressed = () async {
        // ✅ TƯƠNG TỰ CHO MÀN HÌNH ĐIỂM DANH
        final result = await Navigator.push(context, MaterialPageRoute(
            builder: (context) => AttendanceScreen(
              courseTitle: courseTitle,
              classInfo: classInfo, // ✅ Đã cập nhật
              sessionId: session.sessionId!,
            )));
        onNavigateBack(result);
      };
    }

    return Expanded(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(text),
      ),
    );
  }
}