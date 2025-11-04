// [teacher_management.dart] - ĐÃ SỬA LỖI HOÀN CHỈNH
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../controller/app_controller.dart';
import '../../../data/model/teacher.dart';
import '../../../data/model/user_model.dart'; // Import UserModel để dùng cho dropdown

class TeacherManagement extends StatefulWidget {
  const TeacherManagement({super.key});

  @override
  State<TeacherManagement> createState() => _TeacherManagementState();
}

class _TeacherManagementState extends State<TeacherManagement> {
  final TextEditingController _searchController = TextEditingController();
  int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                    'Quản lý giảng viên', // <-- Sửa tiêu đề
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _showAddTeacherDialog(context, controller.users),
                    icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
                    label: const Text('Thêm giảng viên'),
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

              // Search
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo tên giảng viên, khoa...',
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
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Teachers table
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
                      // Lấy dữ liệu giảng viên
                      final all = controller.teachers.where((teacher) {
                        if (_searchController.text.isNotEmpty) {
                          final query = _searchController.text.toLowerCase();
                          final teacherName = (teacher.fullName ?? teacher.userName).toLowerCase();
                          return teacherName.contains(query) ||
                              teacher.department.toLowerCase().contains(query);
                        }
                        return true;
                      }).toList();

                      final total = all.length;
                      final pageCount = (total / _rowsPerPage).ceil();
                      if (_currentPage >= pageCount && pageCount > 0) {
                        _currentPage = pageCount - 1;
                      } else if (pageCount == 0) {
                        _currentPage = 0;
                      }

                      int startIndex = _currentPage * _rowsPerPage;
                      if (startIndex < 0) startIndex = 0;
                      final rawEnd = startIndex + _rowsPerPage;
                      final endIndex = rawEnd > total ? total : rawEnd;
                      final pageItems = (total > 0) ? all.sublist(startIndex, endIndex) : [];

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
                                  label: Text('STT'),
                                  size: ColumnSize.S,
                                ),
                                DataColumn2(
                                  label: Text('Tên giảng viên'),
                                  size: ColumnSize.L,
                                ),
                                DataColumn2(
                                  label: Text('Khoa'),
                                  size: ColumnSize.M,
                                ),
                                DataColumn2(
                                  label: Text('Tổng giờ dạy'),
                                  size: ColumnSize.S,
                                  numeric: true,
                                ),
                                DataColumn2(
                                  label: Text('Thao tác'),
                                  size: ColumnSize.S,
                                ),
                              ],
                              rows: pageItems.asMap().entries.map((entry) {
                                final index = entry.key;
                                final teacher = entry.value;
                                final stt = startIndex + index + 1;

                                return DataRow2(
                                  cells: [
                                    DataCell(Text(stt.toString())),
                                    DataCell(
                                      Text(
                                        teacher.fullName ?? teacher.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(teacher.department)),
                                    DataCell(Text(teacher.totalTeachingHours.toString())),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const FaIcon(FontAwesomeIcons.pen, size: 14),
                                            onPressed: () => _showEditTeacherDialog(context, teacher, controller.users),
                                          ),
                                          IconButton(
                                            icon: const FaIcon(FontAwesomeIcons.trash, size: 14, color: Colors.red),
                                            onPressed: () => _showDeleteConfirmDialog(context, teacher),
                                          ),
                                        ],
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

  void _showAddTeacherDialog(BuildContext context, List<UserModel> allUsers) {
    // Lọc ra những user đã là giảng viên
    final teacherUserIds = context.read<AppController>().teachers.map((t) => t.userId).toSet();
    // Chỉ hiển thị user có vai trò 'Giảng viên' (role=1) và chưa có hồ sơ giảng viên
    final availableUsers = allUsers.where((u) => u.isTeacher && !teacherUserIds.contains(u.id)).toList();

    _showTeacherFormDialog(
      context: context,
      title: 'Thêm giảng viên',
      availableUsers: availableUsers,
      onSubmit: (teacher) async {
        bool ok = false;
        String errorMessage = 'Thêm giảng viên thất bại';
        try {
          ok = await context.read<AppController>().createTeacher(teacher);
        } catch (e) {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
        return {'ok': ok, 'message': ok ? 'Thêm giảng viên thành công' : errorMessage};
      },
    );
  }

  void _showEditTeacherDialog(BuildContext context, Teacher teacher, List<UserModel> allUsers) {
    // Khi sửa, user được chọn phải là chính user đó
    final currentUser = allUsers.firstWhere((u) => u.id == teacher.userId, orElse: () =>
        UserModel(id: teacher.userId, username: teacher.userName, email: '', role: 1) // Tạo user giả nếu không tìm thấy
    );

    _showTeacherFormDialog(
      context: context,
      title: 'Cập nhật giảng viên',
      teacher: teacher,
      availableUsers: [currentUser], // Chỉ cho phép xem, không cho đổi
      isEdit: true,
      onSubmit: (updatedTeacher) async {
        bool ok = false;
        String errorMessage = 'Cập nhật giảng viên thất bại';
        try {
          ok = await context.read<AppController>().updateTeacher(updatedTeacher);
        } catch (e) {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
        return {'ok': ok, 'message': ok ? 'Cập nhật giảng viên thành công' : errorMessage};
      },
    );
  }

  void _showTeacherFormDialog({
    required BuildContext context,
    required String title,
    Teacher? teacher,
    bool isEdit = false,
    required List<UserModel> availableUsers,
    required Future<Map<String, dynamic>> Function(Teacher) onSubmit,
  }) {
    final outerContext = context;
    final formKey = GlobalKey<FormState>();
    UserModel? selectedUser = isEdit ? availableUsers.first : null;
    final departmentController = TextEditingController(text: teacher?.department ?? '');
    final hoursController = TextEditingController(text: teacher?.totalTeachingHours.toString() ?? '0');

    showDialog(
      context: outerContext,
      builder: (dialogCtx) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<UserModel>(
                        value: selectedUser,
                        hint: const Text('Chọn tài khoản người dùng'),
                        // Vô hiệu hóa dropdown nếu đang sửa
                        onChanged: isEdit ? null : (UserModel? user) {
                          setState(() {
                            selectedUser = user;
                          });
                        },
                        items: availableUsers.map((UserModel user) {
                          return DropdownMenuItem<UserModel>(
                            value: user,
                            child: Text(user.fullName ?? user.username),
                          );
                        }).toList(),
                        validator: (value) => value == null ? 'Vui lòng chọn tài khoản' : null,
                        decoration: const InputDecoration(labelText: 'Tài khoản Giảng viên'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: departmentController,
                        decoration: const InputDecoration(labelText: 'Khoa'),
                        validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập khoa' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: hoursController,
                        decoration: const InputDecoration(labelText: 'Tổng giờ dạy (mặc định)'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tổng giờ' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final newTeacher = Teacher(
                        teacherId: teacher?.teacherId, // Giữ ID cũ nếu sửa
                        userId: selectedUser!.id,
                        userName: selectedUser!.fullName ?? selectedUser!.username,
                        department: departmentController.text,
                        totalTeachingHours: int.tryParse(hoursController.text) ?? 0,
                      );

                      final result = await onSubmit(newTeacher);

                      if (Navigator.of(dialogCtx).canPop()) {
                        Navigator.of(dialogCtx).pop();
                      }
                      _showSnack(outerContext, result['message'], result['ok']);
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          }
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Teacher teacher) {
    final outerContext = context;
    showDialog(
      context: outerContext,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa giảng viên "${teacher.fullName ?? teacher.userName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              bool ok = false;
              String errorMessage = 'Xóa giảng viên thất bại';
              try {
                if (teacher.teacherId != null) {
                  ok = await outerContext.read<AppController>().deleteTeacher(teacher.teacherId!);
                }
              } catch (e) {
                errorMessage = e.toString().replaceFirst('Exception: ', '');
              }
              if (Navigator.of(dialogCtx).canPop()) {
                Navigator.of(dialogCtx).pop();
              }
              _showSnack(outerContext, ok ? 'Xóa giảng viên thành công' : errorMessage, ok);
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