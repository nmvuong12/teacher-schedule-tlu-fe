import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../controller/app_controller.dart';
import '../../../data/model/models.dart';

class LeaveRequestManagement extends StatefulWidget {
  const LeaveRequestManagement({super.key});

  @override
  State<LeaveRequestManagement> createState() => _LeaveRequestManagementState();
}

class _LeaveRequestManagementState extends State<LeaveRequestManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Tất cả trạng thái';
  int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Data will be loaded by the router wrapper
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, child) {
        return Container(
          color: Colors.grey[50],
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Quản lý đơn xin nghỉ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 24),
              
              // Search and filter
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm đơn xin nghỉ...',
                        prefixIcon: const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        controller.setSearchKeyword(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Status filter
                  Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'Tất cả trạng thái', child: Text('Tất cả trạng thái')),
                          DropdownMenuItem(value: 'Chờ duyệt', child: Text('Chờ duyệt')),
                          DropdownMenuItem(value: 'Đã phê duyệt', child: Text('Đã phê duyệt')),
                          DropdownMenuItem(value: 'Từ chối', child: Text('Từ chối')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                          controller.setSelectedStatus(value!);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(FontAwesomeIcons.filter, size: 16),
                        SizedBox(width: 8),
                        Text('Lọc'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Leave requests table
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Builder(builder: (context) {
                            final all = controller.filteredTeachingLeaves.where((leave) {
                              if (_searchController.text.isEmpty) return true;
                              final query = _searchController.text.toLowerCase();
                              return leave.reason.toLowerCase().contains(query);
                            }).toList();
                            final total = all.length;
                            final pageCount = (total / _rowsPerPage).ceil();
                            if (_currentPage >= pageCount) {
                              _currentPage = 0;
                            }
                            int startIndex = _currentPage * _rowsPerPage;
                            if (startIndex < 0) startIndex = 0;
                            if (startIndex > total) startIndex = total;
                            final rawEnd = startIndex + _rowsPerPage;
                            final endIndex = rawEnd > total ? total : rawEnd;
                            final pageItems = all.sublist(startIndex, endIndex);

                            return Column(
                              children: [
                                Expanded(
                                  child: DataTable2(
                                    columnSpacing: 12,
                                    horizontalMargin: 12,
                                    minWidth: 1000,
                                    columns: const [
                                      DataColumn2(
                                        label: Text('Giảng viên'),
                                        size: ColumnSize.M,
                                      ),
                                      DataColumn2(
                                        label: Text('Học phần'),
                                        size: ColumnSize.M,
                                      ),
                                      DataColumn2(
                                        label: Text('Ngày nghỉ'),
                                        size: ColumnSize.L,
                                      ),
                                      DataColumn2(
                                        label: Text('Ngày dạy bù'),
                                        size: ColumnSize.L,
                                      ),
                                      DataColumn2(
                                        label: Text('Lý do'),
                                        size: ColumnSize.L,
                                      ),
                                      DataColumn2(
                                        label: Text('Trạng thái'),
                                        size: ColumnSize.S,
                                      ),
                                      DataColumn2(
                                        label: Text('Thao tác'),
                                        size: ColumnSize.S,
                                      ),
                                    ],
                                    rows: pageItems.map((leave) {
                              // Find related session and course section data
                              final session = controller.sessions.firstWhere(
                                (s) => s.sessionId == leave.sessionId,
                                orElse: () => Session(
                                  sessionId: leave.sessionId,
                                  sectionId: 0,
                                  date: DateTime.now(),
                                  classroom: 'N/A',
                                  status: 'N/A',
                                  content: 'N/A',
                                  label: 'N/A',
                                  startTime: DateTime.now(),
                                  endTime: DateTime.now(),
                                ),
                              );
                              
                              final courseSection = controller.courseSections.firstWhere(
                                (cs) => cs.sectionId == session.sectionId,
                                orElse: () => CourseSection(
                                  sectionId: session.sectionId,
                                  classId: 0,
                                  className: 'N/A',
                                  subjectId: 0,
                                  subjectName: 'N/A',
                                  semester: 'N/A',
                                  shift: 'N/A',
                                  startDate: DateTime.now(),
                                  endDate: DateTime.now(),
                                  weeklySessions: 'N/A',
                                  teacherId: 0,
                                  teacherName: 'N/A',
                                ),
                              );
                              
                              final teacher = controller.teachers.firstWhere(
                                (t) => t.teacherId == courseSection.teacherId,
                                orElse: () => Teacher(
                                  teacherId: courseSection.teacherId,
                                  userId: 0,
                                  userName: 'N/A',
                                  department: 'N/A',
                                  totalTeachingHours: 0,
                                ),
                              );

                              return DataRow2(
                                cells: [
                                  DataCell(Text(teacher.userName)),
                                  DataCell(Text('${courseSection.subjectName} - ${courseSection.className}')),
                                  DataCell(Text('${_formatDate(session.date)}, ${session.timeRange}\nPhòng: ${session.classroom}')),
                                  DataCell(Text('${_formatDate(leave.expectedMakeupDate)}\nDạy bù')),
                                  DataCell(Text('${leave.reason}\nGửi: ${_formatDate(DateTime.now())}')),
                                  DataCell(_buildStatusChip(leave.status)),
                                  DataCell(
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (leave.status == 0) // Chờ duyệt
                                            IconButton(
                                              icon: const FaIcon(FontAwesomeIcons.check, size: 14, color: Colors.green),
                                              onPressed: () => _approveLeave(leave),
                                            ),
                                          if (leave.status == 0) // Chờ duyệt
                                            IconButton(
                                              icon: const FaIcon(FontAwesomeIcons.x, size: 14, color: Colors.red),
                                              onPressed: () => _rejectLeave(leave),
                                            ),
                                          if (leave.status != 0) // Không phải chờ duyệt
                                            IconButton(
                                              icon: const FaIcon(FontAwesomeIcons.trash, size: 14, color: Colors.red),
                                              onPressed: () => _showDeleteConfirmDialog(context, leave),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildPaginationBar(total),
                              ],
                            );
                          }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaginationBar(int total) {
    final totalPages = (total / _rowsPerPage).ceil();
    final startItem = _currentPage * _rowsPerPage + 1;
    final endItem = ((_currentPage + 1) * _rowsPerPage).clamp(0, total);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Display info
          Text(
            'Hiển thị $startItem đến $endItem của $total kết quả',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          
          // Right side - Controls
          Row(
            children: [
              // Records per page selector
              const Text(
                'Số bản ghi/trang:',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _rowsPerPage,
                underline: Container(
                  height: 1,
                  color: Colors.grey[400],
                ),
                items: const [
                  DropdownMenuItem(value: 10, child: Text('10')),
                  DropdownMenuItem(value: 20, child: Text('20')),
                  DropdownMenuItem(value: 50, child: Text('50')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _rowsPerPage = value;
                      _currentPage = 0;
                    });
                  }
                },
              ),
              const SizedBox(width: 16),
              
              // Navigation controls
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 16),
                onPressed: _currentPage > 0
                    ? () {
                        setState(() {
                          _currentPage--;
                        });
                      }
                    : null,
                style: IconButton.styleFrom(
                  foregroundColor: _currentPage > 0 ? Colors.blue : Colors.grey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  '${totalPages == 0 ? 0 : _currentPage + 1}/$totalPages',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.chevronRight, size: 16),
                onPressed: (_currentPage + 1) < totalPages
                    ? () {
                        setState(() {
                          _currentPage++;
                        });
                      }
                    : null,
                style: IconButton.styleFrom(
                  foregroundColor: (_currentPage + 1) < totalPages ? Colors.blue : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }


  Widget _buildStatusChip(int status) {
    Color color;
    String text;
    switch (status) {
      case 0: // Chờ duyệt
        color = Colors.orange;
        text = 'Chờ duyệt';
        break;
      case 1: // Đã phê duyệt
        color = Colors.green;
        text = 'Đã phê duyệt';
        break;
      case 2: // Từ chối
        color = Colors.red;
        text = 'Từ chối';
        break;
      default:
        color = Colors.grey;
        text = 'Không xác định';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _approveLeave(TeachingLeave leave) async {
    final outerContext = context;
    bool ok = false;
    String errorMessage = 'Phê duyệt đơn xin nghỉ thất bại';
    try {
      final updatedLeave = TeachingLeave(
        sessionId: leave.sessionId,
        reason: leave.reason,
        expectedMakeupDate: leave.expectedMakeupDate,
        status: 1, // Đã phê duyệt
      );
      ok = await outerContext.read<AppController>().updateTeachingLeave(updatedLeave);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    _showSnack(outerContext, ok ? 'Phê duyệt đơn xin nghỉ thành công' : errorMessage, ok);
  }

  void _rejectLeave(TeachingLeave leave) async {
    final outerContext = context;
    bool ok = false;
    String errorMessage = 'Từ chối đơn xin nghỉ thất bại';
    try {
      final updatedLeave = TeachingLeave(
        sessionId: leave.sessionId,
        reason: leave.reason,
        expectedMakeupDate: leave.expectedMakeupDate,
        status: 2, // Từ chối
      );
      ok = await outerContext.read<AppController>().updateTeachingLeave(updatedLeave);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    _showSnack(outerContext, ok ? 'Từ chối đơn xin nghỉ thành công' : errorMessage, ok);
  }

  void _showDeleteConfirmDialog(BuildContext context, TeachingLeave leave) {
    final outerContext = context;
    showDialog(
      context: outerContext,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa đơn xin nghỉ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              bool ok = false;
              String errorMessage = 'Xóa đơn xin nghỉ thất bại';
              try {
                ok = await outerContext.read<AppController>().deleteTeachingLeave(leave.sessionId);
              } catch (e) {
                errorMessage = e.toString().replaceFirst('Exception: ', '');
              }
              if (Navigator.of(dialogCtx).canPop()) {
                Navigator.of(dialogCtx).pop();
              }
              _showSnack(outerContext, ok ? 'Xóa đơn xin nghỉ thành công' : errorMessage, ok);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message, bool success) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    });
  }
}
