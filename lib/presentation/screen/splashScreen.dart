// [splashScreen.dart] - ĐÃ SỬA LỖI
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Thêm provider
import 'package:schedule_ui/presentation/controller/app_controller.dart'; // Thêm controller
import 'package:schedule_ui/core/api_service/session_manager.dart';
import 'package:schedule_ui/data/model/user_model.dart';
import 'package:schedule_ui/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  void _checkSessionAndNavigate() async {
    // Delay 2 seconds để hiển thị splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Load session từ SharedPreferences
    final (token, user) = await SessionManager.loadSession();

    if (!mounted) return;

    // Nếu có token và user (đã đăng nhập trước đó)
    if (token != null && user != null) {
      // [SỬA LẠI] - Lưu user vào AppController
      // để các nơi khác có thể truy cập nếu cần (như AdminDashboard)
      context.read<AppController>().currentUser = user;

      // [SỬA LẠI] - Điều hướng dựa trên VAI TRÒ (ROLE)
      switch (user.role) {
        case 0: // Admin
          context.go(AppRouter.dashboard);
          break;
        case 1: // Teacher
          context.go(AppRouter.teacherDashboard, extra: user); // Truyền user qua extra
          break;
        case 2: // Student
          context.go(AppRouter.studentDashboard, extra: user); // Truyền user qua extra
          break;
        default:
        // Nếu không có vai trò, về login
          context.go(AppRouter.login);
      }
    } else {
      // Không có session, redirect về LoginScreen
      context.go(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF3C5D93); // close to the screenshot
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school_outlined,
                size: 96,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              const Text(
                'TLU SCHEDULE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}