import 'package:flutter/material.dart';
import '../../../data/repo/student_repository.dart';
import '../../../data/model/section_dto.dart';
import 'student_attendance_screen.dart';

class StudentScheduleScreen extends StatefulWidget {
  final int studentId;
  
  const StudentScheduleScreen({super.key, required this.studentId});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  final StudentRepository _repository = StudentRepository();
  late Future<List<SectionDto>> _futureSections;

  @override
  void initState() {
    super.initState();
    _futureSections = _repository.getSectionsByStudent(widget.studentId);
  }
  
  Future<List<SectionDto>> _getMockData() async {
    // Fake delay giống API call
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      SectionDto(
        sectionId: 1,
        subjectName: 'Lập trình di động',
        weeklySessions: 'Thứ 2 (7h00-9h30)',
      ),
      SectionDto(
        sectionId: 2,
        subjectName: 'Cơ sở dữ liệu',
        weeklySessions: 'Thứ 4 (13h30-16h00)',
      ),
      SectionDto(
        sectionId: 3,
        subjectName: 'Mạng máy tính',
        weeklySessions: 'Thứ 6 (9h30-12h00)',
      ),
    ];
  }

  void _refresh() {
    setState(() {
      _futureSections = _repository.getSectionsByStudent(widget.studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SectionDto>>(
      future: _futureSections,
      builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang tải danh sách học phần...'),
                    ],
                  ),
                );
              }

              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi: ${snap.error}',
                          textAlign: TextAlign.center,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refresh,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final sections = snap.data ?? [];
              if (sections.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có học phần nào',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Bạn chưa có điểm danh nào trong các học phần. Danh sách học phần sẽ hiển thị sau khi giáo viên điểm danh cho bạn trong các buổi học.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Làm mới'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A5BA0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

        // Loại bỏ trùng lặp dựa trên sectionId
        final uniqueSections = <int, SectionDto>{};
        for (final section in sections) {
          uniqueSections[section.sectionId] = section;
        }
        final displaySections = uniqueSections.values.toList();

        // Danh sách học phần
        return Column(
          children: [
            // Tiêu đề với số lượng
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.grey[100],
              child: Text(
                'Danh sách học phần [${displaySections.length} học phần]',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            
            // Danh sách
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: displaySections.length,
                  itemBuilder: (context, index) {
                    final section = displaySections[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên môn học
                            Text(
                              section.subjectName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Thông tin chi tiết
                            if (section.className != null)
                              _buildInfoRow(Icons.book, 'Lớp:', section.className!),
                            if (section.semester != null)
                              _buildInfoRow(Icons.calendar_today, 'Học kỳ:', section.semester!),
                            if (section.shift != null)
                              _buildInfoRow(Icons.access_time, 'Ca học:', section.shift!),
                            if (section.teacherName != null)
                              _buildInfoRow(Icons.person, 'Giảng viên:', section.teacherName!),
                            if (section.weeklySessions != null)
                              _buildInfoRow(Icons.access_time, 'Lịch học:', section.weeklySessions!),
                            const SizedBox(height: 12),
                            // Nút Xem điểm danh
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  print('🔍 Click vào học phần: sectionId=${section.sectionId}, subjectName=${section.subjectName}, studentId=${widget.studentId}');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentAttendanceScreen(
                                        sectionId: section.sectionId,
                                        subjectName: section.subjectName,
                                        studentId: widget.studentId,
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Xem điểm danh',
                                      style: TextStyle(
                                        color: Color(0xFF3A5BA0),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Color(0xFF3A5BA0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

