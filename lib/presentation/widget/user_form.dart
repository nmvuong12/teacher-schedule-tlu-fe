import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/model/models.dart' hide User; // Ẩn User (cũ)
import '../../data/model/user_model.dart'; // Import UserModel (mới)
import '../controller/app_controller.dart';

class UserForm extends StatefulWidget {
  final UserModel? userModel;
  final Function(UserModel) onSubmit;

  const UserForm({
    super.key,
    this.userModel,
    required this.onSubmit,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  int _selectedRole = 1;

  @override
  void initState() {
    super.initState();
    if (widget.userModel != null) {
      _userNameController.text = widget.userModel!.username;
      _passwordController.text = ''; // Don't show password
      _fullNameController.text = widget.userModel!.fullName ?? '';
      _emailController.text = widget.userModel!.email;
      _selectedRole = widget.userModel!.role;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                widget.userModel == null ? 'Thêm người dùng mới' : 'Chỉnh sửa người dùng',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 24),

              // Username
              TextFormField(
                controller: _userNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên đăng nhập',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên đăng nhập';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: widget.userModel == null ? 'Mật khẩu' : 'Mật khẩu mới (để trống nếu không đổi)',
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (widget.userModel == null && (value == null || value.isEmpty)) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Full name
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!value.contains('@')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Role
              DropdownButtonFormField<int>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Admin')),
                  DropdownMenuItem(value: 1, child: Text('Giảng viên')),
                  DropdownMenuItem(value: 2, child: Text('Sinh viên')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
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

                        // [SỬA] - Tạo UserModel (mới) VÀ thêm password
                        final user = UserModel(
                          id: widget.userModel?.id ?? 0,
                          username: _userNameController.text,
                          // [SỬA] - Thêm logic password (giống code cũ)
                          password: _passwordController.text.isNotEmpty
                              ? _passwordController.text
                              : null, // Gửi null nếu không đổi
                          fullName: _fullNameController.text,
                          email: _emailController.text,
                          role: _selectedRole,
                          teacherId: widget.userModel?.teacherId,
                          isActive: widget.userModel?.isActive ?? true,
                        );
                        widget.onSubmit(user);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(widget.userModel == null ? 'Thêm' : 'Cập nhật'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}