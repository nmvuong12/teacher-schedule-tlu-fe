// [login.dart] - ĐÃ SỬA LỖI ĐIỀU HƯỚNG
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:schedule_ui/presentation/screen/forgot_password.dart';
import 'package:schedule_ui/core/api_service/network_service.dart';
import 'package:schedule_ui/core/api_service/session_manager.dart';
import 'package:schedule_ui/presentation/screen/teacher/teacher_main_screen.dart';
import 'package:schedule_ui/router/app_router.dart';

// [SỬA 1] - Thêm 2 imports
import 'package:provider/provider.dart';
import 'package:schedule_ui/presentation/controller/app_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showAuthError = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Debug: In ra password để kiểm tra
    print('🔍 Login Screen - Username: $username');
    print('🔍 Login Screen - Password length: ${password.length}');
    print('🔍 Login Screen - Password preview: ${password.isNotEmpty ? password.substring(0, password.length > 20 ? 20 : password.length) : '(empty)'}');
    
    // Kiểm tra xem password có phải là BCrypt hash không
    final isHashedPassword = password.startsWith('\$2a\$') || 
                             password.startsWith('\$2b\$') || 
                             password.startsWith('\$2y\$');
    
    if (isHashedPassword) {
      // Hiển thị cảnh báo nếu người dùng nhập hash
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vui lòng nhập mật khẩu gốc, không phải mật khẩu đã mã hóa từ database.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Đóng',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _showAuthError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showAuthError = false;
    });

    try {
      final response = await NetworkService.login(username, password);

      if (!mounted) return;

      if (response.success && response.user != null && response.token != null) {
        await SessionManager.saveSession(token: response.token!, userJson: response.user!.toJson());

        // Báo hiệu thành công cho hệ thống Autofill (để lưu MK)
        TextInput.finishAutofillContext(shouldSave: true);

        // [SỬA 2] - Điều hướng dựa trên vai trò của user
        if (mounted) {
          // Lấy user từ response
          final user = response.user!;

          // Lưu user vào AppController
          context.read<AppController>().currentUser = user;

          // Điều hướng dựa trên VAI TRÒ (ROLE)
          switch (user.role) {
            case 0: // Admin
              context.go(AppRouter.dashboard);
              break;
            case 1: // Teacher
              context.go(AppRouter.teacherDashboard);
              break;
            case 2: // Student
              // Truyền studentId và studentName như Map để nhất quán với app_router
              // Ưu tiên dùng studentId từ user, nếu null thì dùng id (fallback)
              final studentId = user.studentId ?? user.id;
              final studentName = user.fullName ?? user.username ?? 'Guest';
              print('🔍 Student login - studentId: $studentId (from user.studentId: ${user.studentId}, user.id: ${user.id})');
              context.go(AppRouter.studentDashboard, extra: {
                'studentId': studentId,
                'studentName': studentName,
              });
              break;
            default:
            // Nếu không có vai trò, về login
              context.go(AppRouter.login);
          }
        }
      } else {
        setState(() {
          _showAuthError = true;
          _isLoading = false;
        });
        TextInput.finishAutofillContext(shouldSave: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Đăng nhập thất bại'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _showAuthError = true;
        _isLoading = false;
      });
      TextInput.finishAutofillContext(shouldSave: false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi kết nối. Vui lòng thử lại sau.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    }
  }

  void _goToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF3C5D93);
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxWebWidth = 480;

    // Logic Adaptive UI: Xác định form sẽ được bọc hay không
    final bool isWebLayout = screenWidth > 600;

    // --- 1. Form Content ---
    Widget formContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Error message
        if (_showAuthError)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD32F2F)),
            ),
            child: Row(
              children: const [
                Icon(Icons.error_outline,
                    color: Color(0xFFD32F2F), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tài khoản hoặc mật khẩu không chính xác',
                    style: TextStyle(
                      color: Color(0xFFD32F2F),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Trường Username
        _RoundedField(
          controller: _usernameController,
          hintText: 'Nhập tài khoản',
          icon: Icons.person_outline,
          isError: _showAuthError,
          keyboardType: TextInputType.text,
          autofillHints: const [AutofillHints.username],
        ),
        const SizedBox(height: 12),

        // Trường Password
        _RoundedField(
          controller: _passwordController,
          hintText: 'Nhập mật khẩu',
          icon: Icons.lock_outline,
          isError: _showAuthError,
          obscureText: true,
          onFieldSubmitted: (_) => _onLogin(),
          autofillHints: const [AutofillHints.password],
        ),
        const SizedBox(height: 20),

        // Nút Đăng nhập
        _PrimaryButton(
          label: _isLoading ? 'ĐANG ĐĂNG NHẬP...' : 'ĐĂNG NHẬP',
          onPressed: _isLoading ? null : _onLogin,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 12),

        // Nút Quên mật khẩu
        _PrimaryButton(
          label: 'QUÊN MẬT KHẨU?',
          onPressed: _goToForgotPassword,
        ),
      ],
    );

    // --- 2. Bọc Form (Áp dụng padding và căn chỉnh) ---
    Widget finalForm;

    if (isWebLayout) {
      // DÀNH CHO WEB: Form không cần padding ngang vì Center và ConstrainedBox sẽ lo
      finalForm = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: maxWebWidth,
          ),
          child: SingleChildScrollView(
            // Chỉ cần padding dọc, bỏ padding ngang (24) trên Web
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: AutofillGroup(
              child: formContent,
            ),
          ),
        ),
      );
    } else {
      // DÀNH CHO ANDROID/MOBILE: Giữ nguyên bố cục Mobile truyền thống
      finalForm = SingleChildScrollView(
        // Áp dụng padding ngang (24) để form không sát lề
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: AutofillGroup(
          child: formContent,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top blue header with icon and title (Giữ nguyên)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 80),
              child: Column(
                children: const [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'HỌC, HỌC NỮA, HỌC MÃI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Form đăng nhập (Sử dụng widget đã bọc)
            Expanded(
              child: finalForm,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget con _RoundedField (Giữ nguyên, chỉ hỗ trợ AutofillHints)
class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isError;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  const _RoundedField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isError = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
        fillColor: Colors.white,
        filled: true,
        prefixIcon: Icon(icon, color: isError ? const Color(0xFFD32F2F) : const Color(0xFF3C5D93)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: isError ? const Color(0xFFD32F2F) : Colors.transparent,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: isError ? const Color(0xFFD32F2F) : Colors.transparent,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: isError ? const Color(0xFFD32F2F) : const Color(0xFF3C5D93),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// Widget con _PrimaryButton (Giữ nguyên)
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _PrimaryButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3C5D93),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}