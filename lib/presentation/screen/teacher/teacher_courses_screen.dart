import 'package:flutter/material.dart';
import '../../../data/model/course_section_model.dart';
import '../../../data/model/user_model.dart'; // Thêm import cho UserModel
import '../../../data/repo/course_section_repository.dart';
import 'attendance_stats_screen.dart';

class TeacherCoursesScreen extends StatefulWidget {
  // 1. THÊM: Tham số để nhận thông tin người dùng đã đăng nhập
  final UserModel user;

  const TeacherCoursesScreen({super.key, required this.user});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  final CourseSectionRepository _repository = CourseSectionRepository();
  late Future<List<GroupedCourse>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    // 2. SỬA: Gọi API mới với teacherId của người dùng
    // Kiểm tra để đảm bảo teacherId không bị null
    if (widget.user.teacherId != null) {
      _coursesFuture = _repository.fetchAndGroupCoursesByTeacher(widget.user.teacherId!);
    } else {
      // Nếu teacherId bị null, trả về lỗi một cách tường minh
      _coursesFuture = Future.error('Không tìm thấy ID của giáo viên.');
    }
  }

  // Thêm hàm refresh để xử lý kéo-để-tải-lại
  Future<void> _refreshCourses() async {
    if (widget.user.teacherId != null) {
      setState(() {
        // 3. SỬA: Cập nhật logic refresh để gọi đúng hàm API
        _coursesFuture = _repository.fetchAndGroupCoursesByTeacher(widget.user.teacherId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder<List<GroupedCourse>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Lỗi tải dữ liệu: ${snapshot.error}', textAlign: TextAlign.center),
                )
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Giáo viên này không có học phần nào.'));
          }

          final courses = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshCourses, // 4. Gắn hàm refresh vào widget
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  'Học phần của bạn (${courses.length} học phần)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                ...courses.map((course) => _buildCourseCard(context, course)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Các hàm build giao diện bên dưới không cần thay đổi ---

  Widget _buildCourseCard(BuildContext context, GroupedCourse course) {
    final academicYear = '${course.startDate.year}-${course.startDate.year + 1}';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.subjectName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'Năm học: $academicYear',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 8),
          Column(
            children: course.classes
                .map((courseClass) => _buildClassRow(context, course, courseClass))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClassRow(BuildContext context, GroupedCourse course, CourseClass courseClass) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            courseClass.name,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceStatsScreen(
                    course: course,
                    courseClass: courseClass,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B57),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            child: const Text('Thống kê điểm danh'),
          ),
        ],
      ),
    );
  }
}

