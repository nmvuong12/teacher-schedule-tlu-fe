import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/model/models.dart';
import '../controller/app_controller.dart';

class TeacherForm extends StatefulWidget {
  final Teacher? teacher;
  final Function(Teacher) onSubmit;

  const TeacherForm({
    super.key,
    this.teacher,
    required this.onSubmit,
  });

  @override
  State<TeacherForm> createState() => _TeacherFormState();
}

class _TeacherFormState extends State<TeacherForm> {
  final _formKey = GlobalKey<FormState>();
  final _departmentController = TextEditingController();
  final _totalTeachingHoursController = TextEditingController();
  
  int? _selectedUserId;
  String _selectedUserName = '';

  @override
  void initState() {
    super.initState();
    if (widget.teacher != null) {
      _selectedUserId = widget.teacher!.userId;
      _selectedUserName = widget.teacher!.userName;
      _departmentController.text = widget.teacher!.department;
      _totalTeachingHoursController.text = widget.teacher!.totalTeachingHours.toString();
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
                    widget.teacher == null ? 'Thêm giảng viên mới' : 'Chỉnh sửa giảng viên',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // User selection
                  Autocomplete<User>(
                    displayStringForOption: (user) => '${user.userName} (${user.fullName})',
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return controller.users.where((u) => u.role == 2); // Only teachers
                      }
                      final query = textEditingValue.text.toLowerCase();
                      return controller.users.where((u) => 
                        u.role == 2 && (u.userName.toLowerCase().contains(query) || 
                                       u.fullName.toLowerCase().contains(query)));
                    },
                    onSelected: (User selection) {
                      _selectedUserId = selection.userId;
                      _selectedUserName = selection.userName;
                    },
                    fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                      textController.text = _selectedUserName;
                      return TextFormField(
                        controller: textController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Chọn người dùng',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_selectedUserId == null) {
                            return 'Vui lòng chọn người dùng';
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
                                  .map((user) => ListTile(
                                        title: Text(user.userName),
                                        subtitle: Text(user.fullName),
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
                  
                  // Department
                  TextFormField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Bộ môn',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập bộ môn';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Total teaching hours
                  TextFormField(
                    controller: _totalTeachingHoursController,
                    decoration: const InputDecoration(
                      labelText: 'Tổng số giờ dạy',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tổng số giờ dạy';
                      }
                      final hours = int.tryParse(value);
                      if (hours == null || hours < 0) {
                        return 'Số giờ dạy phải là số không âm';
                      }
                      return null;
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
                            final teacher = Teacher(
                              teacherId: widget.teacher?.teacherId,
                              userId: _selectedUserId!,
                              userName: _selectedUserName,
                              department: _departmentController.text,
                              totalTeachingHours: int.parse(_totalTeachingHoursController.text),
                            );
                            widget.onSubmit(teacher);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(widget.teacher == null ? 'Thêm' : 'Cập nhật'),
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
    _departmentController.dispose();
    _totalTeachingHoursController.dispose();
    super.dispose();
  }
}
