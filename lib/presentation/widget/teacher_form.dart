// [teacher_form.dart] - ĐÃ SỬA LỖI
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// [SỬA] - Ẩn cả User (cũ) và Teacher (cũ)
import '../../data/model/models.dart' hide User, Teacher;
import '../../data/model/user_model.dart';
import '../../data/model/teacher_model.dart'; // Import Teacher (mới)
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
  final _codeController = TextEditingController(); // Mã giảng viên
  final _degreeController = TextEditingController(); // Học vị
  final _workplaceController = TextEditingController(); // Nơi làm việc
  final _specializationController = TextEditingController(); // Chuyên ngành
  final _phoneController = TextEditingController(); // Số điện thoại
  final _officeController = TextEditingController(); // Văn phòng
  final _emailController = TextEditingController(); // Email
  final _teachingSubjectsController = TextEditingController(); // Môn học giảng dạy
  final _researchFieldsController = TextEditingController(); // Lĩnh vực nghiên cứu
  final _addressController = TextEditingController(); // Địa chỉ
  final _titleController = TextEditingController(); // Chức danh
  final _bioController = TextEditingController(); // Tiểu sử

  int? _selectedUserId;
  String _selectedUserName = '';
  String _selectedFullName = ''; // Thêm để giữ tên đầy đủ
  String? _selectedGender; // Giới tính
  DateTime? _selectedDateOfBirth; // Ngày sinh

  @override
  void initState() {
    super.initState();
    if (widget.teacher != null) {
      _selectedUserId = widget.teacher!.userId;
      _selectedUserName = widget.teacher!.userName;
      _selectedFullName = widget.teacher!.fullName ?? '';
      _departmentController.text = widget.teacher!.department;
      _totalTeachingHoursController.text = widget.teacher!.totalTeachingHours.toString();
      _codeController.text = widget.teacher!.code ?? '';
      _degreeController.text = widget.teacher!.degree ?? '';
      _workplaceController.text = widget.teacher!.workplace ?? '';
      _specializationController.text = widget.teacher!.specialization ?? '';
      _phoneController.text = widget.teacher!.phone ?? '';
      _officeController.text = widget.teacher!.office ?? '';
      _emailController.text = widget.teacher!.email ?? '';
      _teachingSubjectsController.text = widget.teacher!.teachingSubjects ?? '';
      _researchFieldsController.text = widget.teacher!.researchFields ?? '';
      _addressController.text = widget.teacher!.address ?? '';
      _titleController.text = widget.teacher!.title ?? '';
      _bioController.text = widget.teacher!.bio ?? '';
      _selectedGender = widget.teacher!.gender;
      if (widget.teacher!.dateOfBirth != null && widget.teacher!.dateOfBirth!.isNotEmpty) {
        _selectedDateOfBirth = DateTime.tryParse(widget.teacher!.dateOfBirth!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        return Dialog(
            child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxHeight: 800),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
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

                  Autocomplete<UserModel>(
                    displayStringForOption: (user) => '${user.username} (${user.fullName ?? ''})',
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return controller.users.where((u) => u.role == 1);
                      }
                      final query = textEditingValue.text.toLowerCase();
                      return controller.users.where((u) =>
                      u.role == 1 && (u.username.toLowerCase().contains(query) ||
                          (u.fullName ?? '').toLowerCase().contains(query)));
                    },
                    onSelected: (UserModel selection) {
                      _selectedUserId = selection.id;
                      _selectedUserName = selection.username;
                      _selectedFullName = selection.fullName ?? '';
                    },
                    fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                      textController.text = _selectedUserId == null
                          ? ''
                          : '$_selectedUserName (${_selectedFullName.isNotEmpty ? _selectedFullName : 'N/A'})';

                      return TextFormField(
                        controller: textController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Chọn người dùng (giảng viên)',
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
                                title: Text(user.username),
                                subtitle: Text(user.fullName ?? 'N/A'),
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

                  // Code (Mã giảng viên)
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Mã giảng viên',
                      border: OutlineInputBorder(),
                      hintText: 'VD: GV001',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Department
                  TextFormField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Bộ môn *',
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
                      labelText: 'Tổng số giờ dạy *',
                      border: OutlineInputBorder(),
                      hintText: '0',
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
                  const SizedBox(height: 16),

                  // Title (Chức danh)
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Chức danh',
                      border: OutlineInputBorder(),
                      hintText: 'VD: Tiến sĩ, Thạc sĩ',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Degree (Học vị)
                  TextFormField(
                    controller: _degreeController,
                    decoration: const InputDecoration(
                      labelText: 'Học vị',
                      border: OutlineInputBorder(),
                      hintText: 'VD: Tiến sĩ, Thạc sĩ',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Specialization (Chuyên ngành)
                  TextFormField(
                    controller: _specializationController,
                    decoration: const InputDecoration(
                      labelText: 'Chuyên ngành',
                      border: OutlineInputBorder(),
                      hintText: 'VD: Công nghệ thông tin',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      border: OutlineInputBorder(),
                      hintText: 'VD: 0123456789',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      hintText: 'VD: teacher@example.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Office (Văn phòng)
                  TextFormField(
                    controller: _officeController,
                    decoration: const InputDecoration(
                      labelText: 'Văn phòng',
                      border: OutlineInputBorder(),
                      hintText: 'VD: Phòng A101',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Workplace (Nơi làm việc)
                  TextFormField(
                    controller: _workplaceController,
                    decoration: const InputDecoration(
                      labelText: 'Nơi làm việc',
                      border: OutlineInputBorder(),
                      hintText: 'VD: Đại học ABC',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Address (Địa chỉ)
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ',
                      border: OutlineInputBorder(),
                      hintText: 'VD: 123 Đường ABC, Quận XYZ',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDateOfBirth ?? DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDateOfBirth = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Ngày sinh',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedDateOfBirth == null
                            ? 'Chọn ngày sinh'
                            : '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender (Giới tính)
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Giới tính',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                      DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                      DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Teaching Subjects (Môn học giảng dạy)
                  TextFormField(
                    controller: _teachingSubjectsController,
                    decoration: const InputDecoration(
                      labelText: 'Môn học giảng dạy',
                      border: OutlineInputBorder(),
                      hintText: 'VD: Toán học, Vật lý (phân cách bằng dấu phẩy)',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Research Fields (Lĩnh vực nghiên cứu)
                  TextFormField(
                    controller: _researchFieldsController,
                    decoration: const InputDecoration(
                      labelText: 'Lĩnh vực nghiên cứu',
                      border: OutlineInputBorder(),
                      hintText: 'VD: Trí tuệ nhân tạo, Machine Learning (phân cách bằng dấu phẩy)',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Bio (Tiểu sử)
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Tiểu sử',
                      border: OutlineInputBorder(),
                      hintText: 'Mô tả về giảng viên',
                    ),
                    maxLines: 5,
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
                              fullName: _selectedFullName,
                              code: _codeController.text.isEmpty ? null : _codeController.text,
                              department: _departmentController.text,
                              totalTeachingHours: int.parse(_totalTeachingHoursController.text),
                              degree: _degreeController.text.isEmpty ? null : _degreeController.text,
                              workplace: _workplaceController.text.isEmpty ? null : _workplaceController.text,
                              specialization: _specializationController.text.isEmpty ? null : _specializationController.text,
                              phone: _phoneController.text.isEmpty ? null : _phoneController.text,
                              office: _officeController.text.isEmpty ? null : _officeController.text,
                              email: _emailController.text.isEmpty ? null : _emailController.text,
                              teachingSubjects: _teachingSubjectsController.text.isEmpty ? null : _teachingSubjectsController.text,
                              researchFields: _researchFieldsController.text.isEmpty ? null : _researchFieldsController.text,
                              address: _addressController.text.isEmpty ? null : _addressController.text,
                              title: _titleController.text.isEmpty ? null : _titleController.text,
                              bio: _bioController.text.isEmpty ? null : _bioController.text,
                              dateOfBirth: _selectedDateOfBirth != null
                                  ? '${_selectedDateOfBirth!.year}-${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}-${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}'
                                  : null,
                              gender: _selectedGender,
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
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _departmentController.dispose();
    _totalTeachingHoursController.dispose();
    _codeController.dispose();
    _degreeController.dispose();
    _workplaceController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    _officeController.dispose();
    _emailController.dispose();
    _teachingSubjectsController.dispose();
    _researchFieldsController.dispose();
    _addressController.dispose();
    _titleController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}