import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/model/models.dart';
import '../../data/model/user_model.dart';
import '../controller/app_controller.dart';

class StudentForm extends StatefulWidget {
  final Student? student;
  final Function(Student) onSubmit;

  const StudentForm({
    super.key,
    this.student,
    required this.onSubmit,
  });

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _codeController = TextEditingController();
  
  int? _selectedClassId;
  String _selectedClassName = '';
  int? _selectedUserId;
  UserModel? _selectedUser;
  bool _isNameDisabled = false;

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _studentNameController.text = widget.student!.fullName ?? widget.student!.studentName;
      _codeController.text = widget.student!.code ?? '';
      _selectedClassId = widget.student!.classId;
      _selectedClassName = widget.student!.className;
      _selectedUserId = widget.student!.userId;
      _isNameDisabled = widget.student!.userId != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        return Dialog(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.student == null ? 'Thêm sinh viên mới' : 'Chỉnh sửa sinh viên',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // User selection (role = 2 - Sinh viên)
                  Autocomplete<UserModel>(
                    displayStringForOption: (user) => '${user.fullName ?? user.username} (${user.username})',
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      // Chỉ hiển thị users có role = 2 (Sinh viên) và chưa được gán cho student khác
                      final availableUsers = controller.users
                          .where((u) => u.role == 2 && u.id != 0)
                          .where((u) {
                            // Kiểm tra xem user này đã được gán cho student khác chưa
                            final existingStudent = controller.students.firstWhere(
                              (s) => s.userId == u.id,
                              orElse: () => Student(
                                studentId: 0,
                                studentName: '',
                                classId: 0,
                                className: '',
                              ),
                            );
                            // Cho phép user hiện tại (nếu đang edit) hoặc user chưa được gán
                            return existingStudent.studentId == 0 || 
                                   (widget.student != null && existingStudent.studentId == widget.student!.studentId);
                          })
                          .toList();
                      
                      if (textEditingValue.text == '') {
                        return availableUsers;
                      }
                      final query = textEditingValue.text.toLowerCase();
                      return availableUsers.where((u) => 
                        (u.fullName ?? '').toLowerCase().contains(query) ||
                        u.username.toLowerCase().contains(query));
                    },
                    onSelected: (UserModel selection) {
                      setState(() {
                        _selectedUserId = selection.id;
                        _selectedUser = selection;
                        _studentNameController.text = selection.fullName ?? '';
                        _isNameDisabled = true;
                      });
                    },
                    fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                      if (_selectedUser != null) {
                        textController.text = '${_selectedUser!.fullName ?? _selectedUser!.username} (${_selectedUser!.username})';
                      }
                      return TextFormField(
                        controller: textController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Chọn tài khoản người dùng (Sinh viên)',
                          border: OutlineInputBorder(),
                          helperText: 'Chọn tài khoản để tự động điền tên',
                        ),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 500),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: options
                                  .map((user) => ListTile(
                                        title: Text(user.fullName ?? user.username),
                                        subtitle: Text(user.username),
                                        onTap: () => onSelected(user),
                                        dense: true,
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Code
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Mã sinh viên',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Student name (disabled khi đã chọn user)
                  TextFormField(
                    controller: _studentNameController,
                    enabled: !_isNameDisabled,
                    decoration: InputDecoration(
                      labelText: 'Tên sinh viên',
                      border: const OutlineInputBorder(),
                      helperText: _isNameDisabled ? 'Tên được lấy từ tài khoản đã chọn' : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên sinh viên hoặc chọn tài khoản';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Class selection
                  Autocomplete<SchoolClass>(
                    displayStringForOption: (clazz) => clazz.className,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return controller.classes;
                      }
                      final query = textEditingValue.text.toLowerCase();
                      return controller.classes.where((c) => 
                        c.className.toLowerCase().contains(query));
                    },
                    onSelected: (SchoolClass selection) {
                      _selectedClassId = selection.classId;
                      _selectedClassName = selection.className;
                    },
                    fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                      textController.text = _selectedClassName;
                      return TextFormField(
                        controller: textController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Chọn lớp',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_selectedClassId == null) {
                            return 'Vui lòng chọn lớp';
                          }
                          return null;
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 500),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: options
                                  .map((clazz) => ListTile(
                                        title: Text(clazz.className),
                                        onTap: () => onSelected(clazz),
                                        dense: true,
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Hủy'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final student = Student(
                              studentId: widget.student?.studentId ?? 0,
                              studentName: _studentNameController.text,
                              code: _codeController.text.isEmpty ? null : _codeController.text,
                              userId: _selectedUserId,
                              fullName: _selectedUser?.fullName,
                              classId: _selectedClassId!,
                              className: _selectedClassName,
                            );
                            widget.onSubmit(student);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(widget.student == null ? 'Thêm' : 'Cập nhật'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    super.dispose();
  }
}