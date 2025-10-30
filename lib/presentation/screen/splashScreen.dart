import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schedule_ui/presentation/screen/login.dart';
import 'package:schedule_ui/core/api_service/session_manager.dart';
import 'package:schedule_ui/data/model/user_model.dart';
import 'package:schedule_ui/presentation/screen/teacher/teacher_dashboard.dart';
import 'package:schedule_ui/presentation/screen/student/student_dashboard.dart';
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

    if (token != null && user != null) {
    // Redirect tới dashboard
    context.go(AppRouter.dashboard);
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