import 'package:flutter/material.dart';
import 'package:schedule_ui/core/api_service/network_service.dart';
import 'package:schedule_ui/data/model/user_model.dart';
import 'package:schedule_ui/presentation/screen/reset_password.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _sent = false;
    });

    final response = await NetworkService.forgotPassword(email);

    setState(() {
      _isLoading = false;
    });

    if (response.success) {
      setState(() {
        _sent = true;
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
                  Icon(Icons.school_outlined, color: Colors.white, size: 64),
                  SizedBox(height: 12),
                  Text(
                    'Khôi phục mật khẩu',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: _sent
                    ? _Success(onBack: () => Navigator.pop(context))
                    : _Form(
                  formKey: _formKey,
                  emailController: _emailController,
                  onSubmit: _submit,
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                  showInvalid: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool showInvalid;
  final VoidCallback onSubmit;
  final bool isLoading;
  final String? errorMessage;

  const _Form({
    required this.formKey,
    required this.emailController,
    required this.showInvalid,
    required this.onSubmit,
    this.isLoading = false,
    this.errorMessage,
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
          'Khôi phục mật khẩu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Vui lòng nhập email đã đăng ký với tài khoản của bạn. Chúng tôi sẽ gửi link đặt lại mật khẩu vào email của bạn.',
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

        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'email@example.com',
            prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFF98A2B3)),
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
              return 'Vui lòng nhập email.';
            }
            final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
            if (!emailRegex.hasMatch(value)) {
              return 'Email không hợp lệ.';
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
                'GỬI LINK KHÔI PHỤC',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Link to Reset Password screen
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
              );
            },
            child: const Text(
              'Đã có token? Đặt lại mật khẩu ngay',
              style: TextStyle(
                color: Color(0xFF3C5D93),
                fontWeight: FontWeight.w500,
              ),
            ),
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
          child: Icon(Icons.check, size: 40, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Email đã được gửi',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Chúng tôi đã gửi link khôi phục mật khẩu đến email của bạn.\nVui lòng kiểm tra hộp thư của bạn.',
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
            child: const Text('QUAY LẠI ĐĂNG NHẬP',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}




