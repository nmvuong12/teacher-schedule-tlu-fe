import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/repo/attendance_repository.dart';
import '../../../data/model/attendance_dto.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final int sectionId;
  final String subjectName;
  final int studentId;

  const StudentAttendanceScreen({
    super.key,
    required this.sectionId,
    required this.subjectName,
    required this.studentId,
  });

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  late Future<List<AttendanceDto>> _futureAttendance;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  void _loadAttendance() {
    setState(() {
      _futureAttendance = _attendanceRepo.fetchAttendanceListByStudentAndSection(
        widget.studentId,
        widget.sectionId,
      );
    });
  }

  // Format date từ "yyyy-MM-dd" thành "dd/MM/yyyy"
  String? _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  // Parse date từ string thành DateTime
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // Kiểm tra xem date có phải là tương lai không
  bool _isFutureDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    final date = _parseDate(dateStr);
    if (date == null) return false;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.isAfter(todayOnly);
  }

  // Lấy status hiển thị (nếu là tương lai thì "Chưa điểm danh")
  String _getDisplayStatus(AttendanceDto attendance) {
    if (_isFutureDate(attendance.date)) {
      return 'Chưa điểm danh';
    }
    return attendance.statusText;
  }

  // Kiểm tra xem có phải là buổi học đã qua không (để tính phần trăm)
  bool _isPastSession(AttendanceDto attendance) {
    return !_isFutureDate(attendance.date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subjectName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3A5BA0),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttendance,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: FutureBuilder<List<AttendanceDto>>(
        future: _futureAttendance,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải dữ liệu điểm danh...'),
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
                      onPressed: _loadAttendance,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final attendanceList = snap.data ?? [];
          if (attendanceList.isEmpty) {
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
                      'Chưa có dữ liệu điểm danh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Môn học: ${widget.subjectName}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadAttendance,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Làm mới'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A5BA0),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Tính thống kê - chỉ tính các buổi học đã qua
          final pastSessions = attendanceList.where(_isPastSession).toList();
          final present = pastSessions.where((a) => a.isPresent).length;
          final absent = pastSessions.where((a) => a.isAbsent).length;
          final total = pastSessions.length;
          final attendanceRate = total > 0 ? present / total * 100 : 0;

          return Column(
            children: [
              // Thống kê tổng quan
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A5BA0),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tỷ lệ điểm danh',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${attendanceRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      total > 0 
                        ? '$total buổi học đã qua' 
                        : 'Chưa có buổi học nào đã qua',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Thống kê chi tiết với indicator tròn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatIndicator(true, present, 'Có mặt'),
                        _buildStatIndicator(false, absent, 'Vắng'),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Danh sách điểm danh
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadAttendance(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: attendanceList.length,
                    itemBuilder: (context, index) {
                      final attendance = attendanceList[index];
                      final isFuture = _isFutureDate(attendance.date);
                      final displayStatus = _getDisplayStatus(attendance);
                      
                      // Xác định màu và icon dựa trên status hiển thị
                      Color statusColor;
                      IconData statusIcon;
                      if (isFuture) {
                        statusColor = Colors.grey;
                        statusIcon = Icons.schedule;
                      } else if (attendance.isPresent) {
                        statusColor = Colors.green;
                        statusIcon = Icons.check;
                      } else {
                        statusColor = Colors.red;
                        statusIcon = Icons.close;
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Icon trạng thái
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  statusIcon,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Thông tin
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Label (Buổi 1, Buổi 2, ...)
                                    Text(
                                      attendance.label ?? 'Buổi ${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Ngày học
                                    if (attendance.date != null)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDate(attendance.date) ?? attendance.date!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 4),
                                    // Trạng thái
                                    Text(
                                      displayStatus,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }

  Widget _buildStatIndicator(bool isPresent, int count, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isPresent ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPresent ? Icons.check : Icons.close,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
