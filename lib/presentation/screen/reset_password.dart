import 'package:flutter/material.dart';
import 'package:schedule_ui/core/api_service/network_service.dart';
import 'package:schedule_ui/data/model/user_model.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? token; // Token từ deep link hoặc null nếu nhập thủ công

  const ResetPasswordScreen({super.key, this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;
  bool _success = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Nếu có token từ deep link, tự động điền vào
    if (widget.token != null && widget.token!.isNotEmpty) {
      _tokenController.text = widget.token!;
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final token = _tokenController.text.trim();
    final newPassword = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _success = false;
    });

    final response = await NetworkService.resetPassword(token, newPassword);

    setState(() {
      _isLoading = false;
    });

    if (response.success) {
      setState(() {
        _success = true;
      });
    } else {
      setState(() {
        _errorMessage = response.message ?? 'Đã xảy ra lỗi không xác định.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF3C5D93);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                children: const [
                  Icon(Icons.lock_reset, color: Colors.white, size: 64),
                  SizedBox(height: 12),
                  Text(
                    'Đặt lại mật khẩu',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: _success
                    ? _Success(onBack: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Navigator.of(context).pushReplacementNamed('/login');
                      })
                    : _Form(
                        formKey: _formKey,
                        tokenController: _tokenController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        onSubmit: _submit,
                        isLoading: _isLoading,
                        errorMessage: _errorMessage,
                        obscurePassword: _obscurePassword,
                        obscureConfirmPassword: _obscureConfirmPassword,
                        togglePasswordVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        toggleConfirmPasswordVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// WIDGET _FORM
// ------------------------------------------------------------

class _Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController tokenController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;
  final bool isLoading;
  final String? errorMessage;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback togglePasswordVisibility;
  final VoidCallback toggleConfirmPasswordVisibility;

  const _Form({
    required this.formKey,
    required this.tokenController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
    this.isLoading = false,
    this.errorMessage,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.togglePasswordVisibility,
    required this.toggleConfirmPasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF3C5D93);
    final bool isApiError = errorMessage != null;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF3C5D93)),
            label: const Text('Quay lại đăng nhập',
                style: TextStyle(color: Color(0xFF3C5D93))),
          ),
          const SizedBox(height: 8),
          const Text(
            'Đặt lại mật khẩu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhập mã token đã được gửi đến email của bạn và mật khẩu mới.',
            style: TextStyle(color: Color(0xFF667085)),
          ),
          const SizedBox(height: 16),

          if (isApiError)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE9E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFB2B2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFD32F2F)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          if (isApiError) const SizedBox(height: 12),

          // Token field
          TextFormField(
            controller: tokenController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Mã Token',
              hintText: 'Nhập token từ email',
              prefixIcon: const Icon(Icons.vpn_key, color: Color(0xFF98A2B3)),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFF3C5D93), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập token.';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Mật khẩu mới',
              hintText: 'Nhập mật khẩu mới',
              prefixIcon: const Icon(Icons.lock, color: Color(0xFF98A2B3)),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF98A2B3),
                ),
                onPressed: togglePasswordVisibility,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFF3C5D93), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập mật khẩu mới.';
              }
              if (value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự.';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Confirm Password field
          TextFormField(
            controller: confirmPasswordController,
            obscureText: obscureConfirmPassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Xác nhận mật khẩu',
              hintText: 'Nhập lại mật khẩu mới',
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF98A2B3)),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF98A2B3),
                ),
                onPressed: toggleConfirmPasswordVisibility,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFF3C5D93), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng xác nhận mật khẩu.';
              }
              if (value != passwordController.text) {
                return 'Mật khẩu xác nhận không khớp.';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
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
                  : const Text(
                      'ĐẶT LẠI MẬT KHẨU',
                      style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Success extends StatelessWidget {
  final VoidCallback onBack;
  const _Success({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const CircleAvatar(
          radius: 36,
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.check_circle, size: 40, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Đặt lại mật khẩu thành công!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Mật khẩu của bạn đã được cập nhật.\nBạn có thể đăng nhập ngay bây giờ.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF667085)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3C5D93),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 2,
            ),
            child: const Text('ĐI ĐẾN ĐĂNG NHẬP',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

