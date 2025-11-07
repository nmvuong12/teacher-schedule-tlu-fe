// lib/presentation/teacher/screens/attendance_stats_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Model và Repo cần thiết
import '../../../data/model/course_section_model.dart';
import '../../../data/model/session_model.dart';
import '../../../data/repo/session_repository.dart';
// BỔ SUNG: Import 2 file mới
import '../../../data/model/attendance_model.dart';
import '../../../data/repo/attendance_repository.dart';

// THÊM: Import màn hình điểm danh của bạn
import 'attendence_screen.dart';


class AttendanceStatsScreen extends StatefulWidget {
  final GroupedCourse course;
  final CourseClass courseClass;

  const AttendanceStatsScreen({
    super.key,
    required this.course,
    required this.courseClass,
  });

  @override
  State<AttendanceStatsScreen> createState() => _AttendanceStatsScreenState();
}

class _AttendanceStatsScreenState extends State<AttendanceStatsScreen> {
  final SessionRepository _repository = SessionRepository();
  late Future<List<Session>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    // Gọi đúng phương thức `fetchSessionsBySectionId`
    _sessionsFuture = _repository.fetchSessionsBySectionId(widget.courseClass.sectionId);
  }

  void _showAttendanceDetailSheet(BuildContext context, Session session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: _AttendanceDetailContent(
              course: widget.course,
              courseClass: widget.courseClass,
              session: session,
              scrollController: controller,
            ),
          ),
        );
      },
    );
  }

  // SỬA: Hàm điều hướng để truyền đúng tham số cho AttendanceScreen
  void _navigateToAttendance(BuildContext context, Session session) async {
    // Chuẩn bị các biến String mà AttendanceScreen cần
    final String courseTitle = widget.course.subjectName;
    final String classInfo = '${widget.courseClass.name} | ${DateFormat('dd/MM/yyyy').format(session.date)}';

    // Điều hướng đến màn hình điểm danh, và "chờ" kết quả trả về
    final bool? didComplete = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceScreen(
          // Truyền đúng 3 tham số
          courseTitle: courseTitle,
          classInfo: classInfo,
          sessionId: session.sessionId!,
        ),
      ),
    );

    // SAU KHI QUAY LẠI TỪ MÀN HÌNH ĐIỂM DANH:
    if (didComplete == true && mounted) {
      // Gọi setState và tải lại future để refresh dữ liệu
      setState(() {
        _sessionsFuture = _repository.fetchSessionsBySectionId(widget.courseClass.sectionId);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final academicYear = '${widget.course.startDate.year}-${widget.course.startDate.year + 1}';

    return Scaffold(
      backgroundColor: const Color(0xFF3B5998), // Màu nền xanh của AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Thống kê điểm danh", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Column(
            children: [
              // --- Phần Header với thông tin lớp ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.course.subjectName} | ${widget.courseClass.name}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Năm học $academicYear',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // --- Phần Body với FutureBuilder ---
              Expanded(
                child: FutureBuilder<List<Session>>(
                  future: _sessionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Lỗi tải dữ liệu buổi học: ${snapshot.error}', textAlign: TextAlign.center),
                      ));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Lớp này chưa có buổi học nào được ghi nhận.'));
                    }

                    final filteredSessions = snapshot.data!;

                    // [SỬA] - Sắp xếp theo thứ tự từ bé đến lớn (cũ nhất, sớm nhất trước)
                    filteredSessions.sort((a, b) {
                      // 1. Ưu tiên sắp xếp theo ngày (từ cũ đến mới)
                      int dateCompare = a.date.compareTo(b.date);

                      // Nếu ngày khác nhau, trả về kết quả so sánh ngày
                      if (dateCompare != 0) {
                        return dateCompare;
                      }

                      // 2. Nếu cùng ngày, sắp xếp theo giờ bắt đầu (từ sớm đến muộn)
                      return a.startTime.compareTo(b.startTime);
                    });

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildStatsTable(context, filteredSessions),
                    );
                  },
                ),
              ),
              // --- Phần Footer ---
              _buildFooterButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsTable(BuildContext context, List<Session> sessions) {
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
        4: FlexColumnWidth(),
        5: IntrinsicColumnWidth(),
      },
      border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
      children: [
        _buildHeaderRow(),
        ...List.generate(sessions.length, (index) {
          final session = sessions[index];
          // SỬA: Truyền thêm các tham số mới cho _buildDataRow
          return _buildDataRow(
            context,
            index + 1,
            session,
            (session.studentCount != null), // bool: kiểm tra có stats (dữ liệu) chưa
                () => _showAttendanceDetailSheet(context, session), // Hàm "Xem"
                () => _navigateToAttendance(context, session), // Hàm "Điểm danh"
          );
        }),
      ],
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
      children: [
        _buildHeaderCell('STT'),
        _buildHeaderCell('Ngày học'),
        _buildHeaderCell('Tổng SV'),
        _buildHeaderCell('Có mặt'),
        _buildHeaderCell('Vắng'),
        _buildHeaderCell('Xem'), // SỬA: Tiêu đề cột cuối, có thể đổi thành "Hành động"
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // SỬA: Thêm tham số bool hasStats và VoidCallback onTakeAttendance
  TableRow _buildDataRow(
      BuildContext context,
      int stt,
      Session session,
      bool hasStats, // THÊM MỚI
      VoidCallback onView,
      VoidCallback onTakeAttendance, // THÊM MỚI
      ) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(session.date);

    // Dữ liệu sẽ là '?' nếu studentCount là null
    final totalStudents = session.studentCount?.toString() ?? '?';
    final presentCount = session.presentCount?.toString() ?? '?';
    final absentCount = session.absentCount?.toString() ?? '?';

    return TableRow(
      children: [
        _buildDataCell(stt.toString()),
        _buildDataCell(formattedDate),
        _buildDataCell(totalStudents), // Tổng SV
        _buildDataCell(presentCount), // Có mặt
        _buildDataCell(absentCount, color: hasStats ? Colors.red : Colors.grey), // Vắng
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          // SỬA: Hiển thị nút "Xem" hoặc nút "Điểm danh" tùy vào `hasStats`
          child: hasStats
              ? IconButton(
            // Nếu CÓ stats, hiện nút "Xem chi tiết"
            icon: Icon(Icons.visibility_outlined, color: Colors.grey.shade600),
            onPressed: onView,
          )
              : IconButton(
            // Nếu CHƯA CÓ stats (là dấu '?'), hiện nút "Điểm danh"
            icon: Icon(Icons.edit_calendar_outlined, color: Colors.blueAccent),
            onPressed: onTakeAttendance,
          ),
        ),
      ],
    );
  }

  Widget _buildDataCell(String text, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: color)),
    );
  }

  Widget _buildFooterButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Quay lại', style: TextStyle(fontSize: 16, color: Colors.black54)),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// KHÔNG THAY ĐỔI GÌ Ở WIDGET BÊN DƯỚI NÀY
// =================================================================
class _AttendanceDetailContent extends StatefulWidget {
  final GroupedCourse course;
  final CourseClass courseClass;
  final Session session;
  final ScrollController scrollController;

  const _AttendanceDetailContent({
    required this.course,
    required this.courseClass,
    required this.session,
    required this.scrollController,
  });

  @override
  State<_AttendanceDetailContent> createState() => _AttendanceDetailContentState();
}

class _AttendanceDetailContentState extends State<_AttendanceDetailContent> {
  // THÊM: Repository và Future để gọi API
  final AttendanceRepository _repository = AttendanceRepository();
  late Future<List<Attendance>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    // THÊM: Gọi API khi widget được khởi tạo
    _attendanceFuture = _repository.fetchAttendancesForSession(widget.session.sessionId!);
  }

  @override
  Widget build(BuildContext context) {
    final academicYear = '${widget.course.startDate.year}-${widget.course.startDate.year + 1}';
    final formattedDate = DateFormat('dd/MM/yyyy').format(widget.session.date);

    return Column(
      children: [
        // --- Header của Bottom Sheet ---
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Danh sách điểm danh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.course.subjectName} | ${widget.courseClass.name}', style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                'Năm học: $academicYear | Ngày: $formattedDate',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        const Divider(height: 24),
        // --- Body của Bottom Sheet (thay bằng FutureBuilder) ---
        Expanded(
          // SỬA: Dùng FutureBuilder để tải dữ liệu thật
          child: FutureBuilder<List<Attendance>>(
            future: _attendanceFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Lỗi tải danh sách: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Không có dữ liệu điểm danh.'));
              }

              final studentList = snapshot.data!;

              // Dùng ListView.builder để hiển thị
              return ListView.builder(
                controller: widget.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: studentList.length + 1, // +1 cho header
                itemBuilder: (ctx, index) {
                  if (index == 0) return _buildDetailHeaderRow();
                  final student = studentList[index - 1]; // Lấy SV thật
                  return _buildDetailDataRow(index, student); // Truyền SV thật
                },
              );
            },
          ),
        ),
        // --- Footer của Bottom Sheet ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Quay lại', style: TextStyle(fontSize: 16, color: Colors.black54)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          _buildDetailHeaderCell('STT', 1),
          _buildDetailHeaderCell('Họ tên', 4),
          _buildDetailHeaderCell('Có/Vắng', 2),
        ],
      ),
    );
  }

  Widget _buildDetailHeaderCell(String text, int flex) {
    return Expanded(flex: flex, child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)));
  }

  // SỬA: Nhận model Attendance thật thay vì mẫu
  Widget _buildDetailDataRow(int stt, Attendance student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(stt.toString(), style: const TextStyle(fontSize: 13))),
          Expanded(flex: 4, child: Text(student.studentName, style: const TextStyle(fontSize: 13))),
          // ĐÃ XÓA 2 CỘT Mã SV VÀ Lớp Ở ĐÂY
          Expanded(
            flex: 2,
            child: Icon(
              student.isPresent ? Icons.check_circle : Icons.remove_circle, // Sửa: Dùng getter
              color: student.isPresent ? Colors.green : Colors.red, // Sửa: Dùng getter
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}