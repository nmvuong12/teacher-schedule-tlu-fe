import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../controller/app_controller.dart';
import '../../../data/model/models.dart';
import '../../widget/course_section_form.dart';

class CourseManagement extends StatefulWidget {
  const CourseManagement({super.key});

  @override
  State<CourseManagement> createState() => _CourseManagementState();
}

class _CourseManagementState extends State<CourseManagement> {
  final TextEditingController _searchController = TextEditingController();
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
              Row(
                children: [
                  const Text(
                    'Quản lý học phần',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCourseDialog(context),
                    icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
                    label: const Text('Thêm học phần'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
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
                        hintText: 'Tìm kiếm học phần...',
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
              
              // Course sections table
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
                            final all = controller.filteredCourseSections;
                            final total = all.length;
                            final pageCount = (total / _rowsPerPage).ceil();
                            if (_currentPage >= pageCount) {
                              _currentPage = 0; // reset when no data or page shrink
                            }
                            int startIndex = _currentPage * _rowsPerPage;
                            if (startIndex < 0) startIndex = 0;
                            if (startIndex > total) startIndex = total;
                            final rawEnd = startIndex + _rowsPerPage;
                            final endIndex = rawEnd > total ? total : rawEnd;
                            final pageItems = all.sublist(startIndex, endIndex);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: DataTable2(
                                    columnSpacing: 12,
                                    horizontalMargin: 12,
                                    minWidth: 800,
                                    columns: const [
                                      DataColumn2(
                                        label: Text('Mã học phần'),
                                        size: ColumnSize.S,
                                      ),
                                      DataColumn2(
                                        label: Text('Tên học phần'),
                                        size: ColumnSize.L,
                                      ),
                                      DataColumn2(
                                        label: Text('Lớp học'),
                                        size: ColumnSize.M,
                                      ),
                                      DataColumn2(
                                        label: Text('Buổi trong tuần'),
                                        size: ColumnSize.M,
                                      ),
                                      DataColumn2(
                                        label: Text('Giảng viên'),
                                        size: ColumnSize.L,
                                      ),
                                      DataColumn2(
                                        label: Text('Trạng thái'),
                                        size: ColumnSize.M,
                                      ),
                                      DataColumn2(
                                        label: Text('Thao tác'),
                                        size: ColumnSize.S,
                                      ),
                                    ],
                                    rows: pageItems.map((section) {
                                      final editable = section.status == 'Chưa bắt đầu';
                                      return DataRow2(
                                        cells: [
                                          DataCell(Text('IT${(section.sectionId ?? 0).toString().padLeft(4, '0')}')),
                                          DataCell(Text(section.subjectName)),
                                          DataCell(Text(section.className)),
                                          DataCell(Text(section.weeklySessions)),
                                          DataCell(Text(section.teacherName)),
                                          DataCell(_buildStatusChip(section.displayStatus)),
                                          DataCell(
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (editable)
                                                    IconButton(
                                                      icon: const FaIcon(FontAwesomeIcons.pen, size: 14),
                                                      onPressed: () => _showEditCourseDialog(context, section),
                                                    )
                                                  else
                                                    IconButton(
                                                      icon: const FaIcon(FontAwesomeIcons.eye, size: 14),
                                                      onPressed: () => _showViewDetailDialog(context, section),
                                                    ),
                                                  IconButton(
                                                    icon: const FaIcon(FontAwesomeIcons.trash, size: 14, color: Colors.red),
                                                    onPressed: () => _showDeleteConfirmDialog(context, section),
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
              
              // Pagination placeholder removed; handled inside table card
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Đang hoạt động':
      case 'Đang diễn ra':
        color = Colors.green;
        break;
      case 'Chưa bắt đầu':
        color = Colors.orange;
        break;
      case 'Đã kết thúc':
      case 'Kết thúc':
        color = Colors.grey;
        break;
      case 'Đã hủy':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPaginationBar(int total) {
    final totalPages = (total / _rowsPerPage).ceil();
    final showingStart = total == 0 ? 0 : _currentPage * _rowsPerPage + 1;
    final showingEnd = ((
      (_currentPage + 1) * _rowsPerPage
    ) > total ? total : ((_currentPage + 1) * _rowsPerPage));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hiển thị $showingStart đến $showingEnd của $total kết quả',
          style: const TextStyle(color: Colors.grey),
        ),
        Row(
          children: [
            const Text('Số bản ghi/trang: '),
            DropdownButton<int>(
              value: _rowsPerPage,
              items: const [10, 20, 50]
                  .map((n) => DropdownMenuItem<int>(value: n, child: Text('$n')))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _rowsPerPage = value;
                  _currentPage = 0;
                });
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 16),
              onPressed: _currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                  : null,
            ),
            Text('${totalPages == 0 ? 0 : _currentPage + 1}/$totalPages'),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.chevronRight, size: 16),
              onPressed: (_currentPage + 1) < totalPages
                  ? () {
                      setState(() {
                        _currentPage++;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  void _showViewDetailDialog(BuildContext context, CourseSection courseSection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết học phần'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã: IT${(courseSection.sectionId ?? 0).toString().padLeft(4, '0')}'),
            Text('Môn: ${courseSection.subjectName}'),
            Text('Lớp: ${courseSection.className}'),
            Text('GV: ${courseSection.teacherName}'),
            Text('Học kỳ: ${courseSection.semester}'),
            Text('Ca: ${courseSection.shift}'),
            Text('Từ: ${courseSection.startDate.toIso8601String().split('T')[0]}'),
            Text('Đến: ${courseSection.endDate.toIso8601String().split('T')[0]}'),
            Text('Buổi trong tuần: ${courseSection.weeklySessions}'),
            Text('Trạng thái: ${courseSection.status}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
  void _showAddCourseDialog(BuildContext context) {
    final outerContext = context;
    showDialog(
      context: outerContext,
      builder: (dialogCtx) => CourseSectionForm(
        onSubmit: (courseSection) async {
          bool ok = false;
          String errorMessage = 'Thêm học phần thất bại';
          try {
            ok = await outerContext.read<AppController>().createCourseSection(courseSection);
          } catch (e) {
            errorMessage = e.toString().replaceFirst('Exception: ', '');
          }
          if (ok) {
            Navigator.of(dialogCtx).pop();
            _showSnack(outerContext, 'Thêm học phần thành công', true);
          } else {
            _showSnack(outerContext, errorMessage, false);
          }
        },
      ),
    );
  }

  void _showEditCourseDialog(BuildContext context, CourseSection courseSection) {
    final outerContext = context;
    showDialog(
      context: outerContext,
      builder: (dialogCtx) => CourseSectionForm(
        courseSection: courseSection,
        onSubmit: (updatedCourseSection) async {
          bool ok = false;
          String errorMessage = 'Cập nhật học phần thất bại';
          try {
            ok = await outerContext.read<AppController>().updateCourseSection(updatedCourseSection);
          } catch (e) {
            errorMessage = e.toString().replaceFirst('Exception: ', '');
          }
          if (ok) {
            Navigator.of(dialogCtx).pop();
            _showSnack(outerContext, 'Cập nhật học phần thành công', true);
          } else {
            _showSnack(outerContext, errorMessage, false);
          }
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, CourseSection courseSection) {
    final outerContext = context;
    showDialog(
      context: outerContext,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa học phần "${courseSection.subjectName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              bool ok = false;
              String errorMessage = 'Xóa học phần thất bại';
              try {
                if (courseSection.sectionId != null) {
                  ok = await outerContext.read<AppController>().deleteCourseSection(courseSection.sectionId!);
                }
              } catch (e) {
                errorMessage = e.toString().replaceFirst('Exception: ', '');
              }
              if (Navigator.of(dialogCtx).canPop()) {
                Navigator.of(dialogCtx).pop();
              }
              _showSnack(outerContext, ok ? 'Xóa học phần thành công' : errorMessage, ok);
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
