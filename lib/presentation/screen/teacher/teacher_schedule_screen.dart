import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'leave_request_screen.dart';
import '../../../core/api_client.dart';
import '../../../core/api_service/session_manager.dart';
import '../../../data/model/user_model.dart';
import '../../../data/model/session_dto.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  late Future<List<SessionDto>> future;

  @override
  void initState() {
    super.initState();
    print('TeacherScheduleScreen: initState - Starting to fetch data');
    _loadSessionsFromSession();
  }

  Future<void> _loadSessionsFromSession() async {
    try {
      final (_, userJson) = await SessionManager.loadSession();
      if (userJson != null) {
        final user = UserModel.fromJson(userJson);
        final teacherId = user.teacherId ?? user.id;
        
        print('🔍 TeacherScheduleScreen: Loading sessions from session');
        print('📦 teacherId: $teacherId, userId: ${user.id}');
        
        if (teacherId != null && teacherId > 0) {
          setState(() {
            future = _fetchSessions(teacherId);
          });
        } else {
          print('⚠️ TeacherScheduleScreen: No valid teacherId found');
          setState(() {
            future = Future.error('Tài khoản giáo viên không hợp lệ (thiếu teacherId)');
          });
        }
      } else {
        print('⚠️ TeacherScheduleScreen: No session found');
        setState(() {
          future = Future.error('Không tìm thấy thông tin đăng nhập');
        });
      }
    } catch (e) {
      print('❌ TeacherScheduleScreen: Error loading session: $e');
      setState(() {
        future = Future.error('Lỗi khi tải thông tin: $e');
      });
    }
  }

  Future<List<SessionDto>> _fetchSessions(int teacherId) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/api/sessions/scheduled/teacher/$teacherId');
    print('📞 Calling API: $uri');
    
    final res = await http.get(uri, headers: ApiClient.jsonHeaders).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('Kết nối timeout sau 30 giây. Vui lòng kiểm tra backend có đang chạy không.');
      },
    );
    print('📥 Response status: ${res.statusCode}');
    print('📥 Response body length: ${res.body.length} chars');
    
    if (res.statusCode != 200) {
      throw Exception('GET scheduled by teacher failed: ${res.statusCode} ${res.body}');
    }
    final List data = json.decode(res.body) as List;
    print('✅ Parsed ${data.length} sessions');
    
    // Parse tất cả sessions
    final allSessions = data.map((e) => SessionDto.fromJson(e)).toList();
    
    // Debug: In ra tất cả status để kiểm tra
    print('🔍 All session statuses:');
    for (var session in allSessions) {
      print('  - Session ${session.sessionId}: status="${session.status}"');
    }
    
    // Filter loại bỏ các session đã hủy
    final activeSessions = allSessions.where((session) {
      final status = session.status.trim();
      
      // Kiểm tra chính xác status "Đã hủy" (tiếng Việt) hoặc "cancelled" (tiếng Anh)
      // Sử dụng so sánh chính xác và contains để bắt tất cả các biến thể
      final statusLower = status.toLowerCase();
      final isCancelled = status == 'Đã hủy' ||
                         status == 'đã hủy' ||
                         statusLower == 'cancelled' ||
                         statusLower.contains('hủy') ||
                         statusLower.contains('cancelled');
      
      if (isCancelled) {
        print('❌ Filtering out cancelled session ${session.sessionId}: status="$status"');
        return false;
      }
      
      return true;
    }).toList();
    
    print('✅ Filtered: ${activeSessions.length} active sessions (removed ${allSessions.length - activeSessions.length} cancelled sessions)');
    
    return activeSessions;
  }

  void _refresh() async {
    await _loadSessionsFromSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SessionDto>>(
      future: future,
      builder: (context, snap) {
        print('TeacherScheduleScreen: FutureBuilder - ConnectionState: ${snap.connectionState}');
        print('TeacherScheduleScreen: FutureBuilder - HasData: ${snap.hasData}');
        print('TeacherScheduleScreen: FutureBuilder - HasError: ${snap.hasError}');
        if (snap.hasData) {
          print('TeacherScheduleScreen: Data received - ${snap.data?.length} sessions');
        }
        if (snap.hasError) {
          print('TeacherScheduleScreen: Error - ${snap.error}');
        }
        
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang tải lịch dạy...'),
              ],
            ),
          );
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Lỗi: ${snap.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Không có lịch dạy'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Làm mới'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            _refresh();
            await future;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
            final s = items[index];
            final timeRange = s.timeRange;
            
            // Ưu tiên hiển thị tên môn học, nếu không có thì dùng label hoặc content
            String title;
            if (s.subjectName != null && s.subjectName!.isNotEmpty) {
              title = s.subjectName!; // "Lập trình web nâng cao"
            } else if (s.label != null && s.label!.isNotEmpty) {
              title = s.label!; // "Buổi 12"
            } else {
              title = 'Buổi học ${s.sessionId}';
            }
            
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${s.formattedDate}  |  $timeRange  |  ${s.classroom}  |  ${s.status}',
                    style: const TextStyle(color: Colors.black54)),
                children: [
                  _row('Ngày', s.formattedDate),
                  _row('Bắt đầu', s.formattedStartTime),
                  _row('Kết thúc', s.formattedEndTime),
                  _row('Phòng', s.classroom),
                  _row('Trạng thái', s.status),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Dismiss tất cả SnackBar trước khi chuyển màn hình
                        ScaffoldMessenger.of(context).clearSnackBars();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LeaveRequestScreen(),
                            settings: RouteSettings(
                              arguments: {
                                'title': title,
                                'sessionId': s.sessionId,
                                'subjectName': s.subjectName, // Thêm subjectName
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A5BA0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Đăng ký nghỉ dạy'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        );
      },
    );
  }
}

Widget _row(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.black54))),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

// Đã chuyển sang lấy dữ liệu từ backend, bỏ mock types



