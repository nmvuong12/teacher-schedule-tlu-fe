import 'package:flutter/material.dart';
// 1. Import model và repository chính xác cho chức năng điểm danh
import '../../../data/model/attendance_model.dart';
import '../../../data/model/session_model.dart';
import '../../../data/repo/attendance_repository.dart';
import '../../../data/repo/session_repository.dart';

class AttendanceScreen extends StatefulWidget {
  final String courseTitle;
  final String classInfo;
  // 2. Thêm sessionId để biết cần lấy dữ liệu cho buổi học nào
  final int sessionId;

  const AttendanceScreen({
    super.key,
    required this.courseTitle,
    required this.classInfo,
    required this.sessionId, // Thêm vào constructor
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // 3. Khai báo state để quản lý dữ liệu từ API
  final AttendanceRepository _repository = AttendanceRepository();
  late Future<List<Attendance>> _attendanceFuture;
  List<Attendance>? _attendanceList; // Dùng để lưu trữ và cập nhật UI

  // State để quản lý nút loading cho từng sinh viên và nút lưu tổng
  final Set<int> _updatingStudents = {};
  bool _isFinishing = false; // Đổi tên _isSaving thành _isFinishing

  // 0: Hôm nay, 1: Lịch dạy, 2: Tái lịch
  int _selectedIndex = 0;

  // Màu chính từ TeacherMainScreen
  static const Color _primaryColor = Color(0xFF3B5998);

  @override
  void initState() {
    super.initState();
    // 4. Gọi API để lấy dữ liệu khi màn hình khởi tạo
    _loadAttendances();
  }

  void _loadAttendances() {
    setState(() {
      _attendanceFuture = _repository.fetchAttendancesForSession(widget.sessionId);
    });
  }

  // Phương thức hiển thị Dialog chung cho Success
  Future<void> _showSuccessDialog() async {
    // Cập nhật completion status trước khi hiển thị dialog
    // await _updateSessionCompletionStatus(); // Tạm thời bỏ qua bước này để đơn giản hóa

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });

        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.lightGreen.shade200, width: 3),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Hoàn tất điểm danh!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        Navigator.of(context).pop(true); // Quay lại màn hình trước
      }
    });
  }

  // Method để cập nhật completion status của session
  // (Hàm này đang tham chiếu đến model Session cũ, cần sửa lại nếu dùng)
  /* Future<void> _updateSessionCompletionStatus() async {
    try {
      final sessionRepository = SessionRepository();
      final latestSession = await sessionRepository.fetchSessionById(widget.sessionId);

      bool isAttendanceCompleted = _attendanceList?.isNotEmpty == true &&
        _attendanceList!.any((attendance) => attendance.status.toUpperCase() == 'PRESENT');

      // ... Cần tạo session object đầy đủ ở đây ...
      // final updatedSession = Session( ... );

      // await sessionRepository.updateSessionDetails(updatedSession);
      debugPrint('✅ Updated session completion status - Attendance: $isAttendanceCompleted');

    } catch (e) {
      debugPrint('❌ Error updating session completion status: $e');
    }
  }
  */

  // Phương thức hiển thị hộp thoại xác nhận hủy
  Future<bool> _showCancelConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('XÁC NHẬN HỦY', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Bạn có chắc chắn muốn hủy?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Có'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  // Xử lý khi nhấn nút quay lại của hệ thống
  Future<bool> _onWillPop() async {
    if (_isFinishing) return false;
    return await _showCancelConfirmationDialog();
  }

  // Widget phụ trợ cho thanh Tab Bar (giả lập)
  Widget _tabItem(String title, int index) {
    bool isSelected = _selectedIndex == index;
    const Color selectedColor = Colors.white;
    const Color unselectedColor = Colors.white70;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            setState(() {
              _selectedIndex = index;
            });
            // Lưu ý: Việc nhấn tab ở đây không có tác dụng
            // vì đây là màn hình chi tiết, không phải màn hình chính
          }
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.yellow : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? selectedColor : unselectedColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          if (await _onWillPop()) {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: _primaryColor,
          title: const Text('TLU Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          centerTitle: true,
          // Nút back sẽ tự động có màu trắng do iconTheme
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Container(
              color: _primaryColor,
              child: Row(
                children: [
                  _tabItem('Hôm nay', 0),
                  _tabItem('Lịch dạy', 1),
                  _tabItem('Học phần', 2),
                  _tabItem('Thông tin', 3),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _buildClassInfoCard(),
                // 5. Sử dụng FutureBuilder để hiển thị danh sách
                Expanded(child: _buildBody()),
              ],
            ),
            Positioned(bottom: 0, left: 0, right: 0, child: _buildFooter()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<Attendance>>(
      future: _attendanceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lỗi: ${snapshot.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadAttendances, child: const Text('Thử lại')),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có sinh viên trong lớp này.'));
        }

        _attendanceList ??= snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80), // Chừa không gian cho footer
          itemCount: _attendanceList!.length,
          itemBuilder: (context, index) {
            final attendance = _attendanceList![index];
            return _buildStudentItem(attendance, index + 1);
          },
        );
      },
    );
  }

  Widget _buildClassInfoCard() {
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Điểm danh lớp', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: _isFinishing ? null : () async {
                  if (await _onWillPop()) {
                    Navigator.of(context).pop(false);
                  }
                },
              ),
            ],
          ),
          const Divider(height: 10, thickness: 0.5),
          const SizedBox(height: 8),
          Text(widget.courseTitle, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 4),
          Text(widget.classInfo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  // 6. Cập nhật Item sinh viên để dùng model `Attendance` và gọi API
  Widget _buildStudentItem(Attendance attendance, int index) {
    // Sửa: 'PRESENT' và 'ABSENT' là các hằng số
    final bool isPresent = attendance.status.toUpperCase() == 'CÓ MẶT';
    final bool isUpdating = _updatingStudents.contains(attendance.studentId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 30, child: Text('$index')),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attendance.studentName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Spacer(flex: 2), // Bỏ cột Lớp để giao diện thoáng hơn
          GestureDetector(
            // 7. Logic gọi API khi nhấn vào nút điểm danh
            onTap: isUpdating ? null : () async {
              // Sửa: Dùng đúng hằng số status
              final newStatus = isPresent ? 'Vắng' : 'Có mặt';
              setState(() => _updatingStudents.add(attendance.studentId));
              try {
                // ================== SỬA LỖI TẠI ĐÂY ==================

                // ✅ SỬA 2: Bổ sung các trường required `studentCode` và `className`
                final updatedAttendanceRequest = Attendance(
                  sessionId: attendance.sessionId,
                  studentId: attendance.studentId,
                  studentName: attendance.studentName,
                  status: newStatus,
                  studentCode: attendance.studentCode, // Thêm dòng này
                  className: attendance.className,     // Thêm dòng này
                );

                // ✅ SỬA 1: Sửa tên phương thức từ 'updateAttendanceStatus' thành 'updateAttendance'
                await _repository.updateAttendance(updatedAttendanceRequest);

                // ================== KẾT THÚC SỬA LỖI ==================

                // Cập nhật UI nếu thành công
                setState(() => attendance.status = newStatus);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cập nhật thất bại: $e'), backgroundColor: Colors.red),
                  );
                }
              } finally {
                setState(() => _updatingStudents.remove(attendance.studentId));
              }
            },
            child: isUpdating
                ? const SizedBox(width: 30, height: 30, child: Padding(padding: EdgeInsets.all(5.0), child: CircularProgressIndicator(strokeWidth: 2)))
                : Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isPresent ? Colors.green : Colors.red, width: 1.5),
              ),
              child: Icon(isPresent ? Icons.check : Icons.close, color: isPresent ? Colors.green : Colors.red, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // 8. Cập nhật Footer
  Widget _buildFooter() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _isFinishing ? null : () async {
                if (await _onWillPop()) Navigator.of(context).pop(false);
              },
              child: Text('Hủy', style: TextStyle(color: _isFinishing ? Colors.grey : Colors.red, fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: _isFinishing || _updatingStudents.isNotEmpty ? null : () async {
                setState(() => _isFinishing = true);
                await _showSuccessDialog();
                // Pop đã được gọi trong dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFinishing || _updatingStudents.isNotEmpty ? Colors.grey : const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isFinishing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Hoàn tất điểm danh', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}