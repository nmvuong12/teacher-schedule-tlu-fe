import 'package:flutter/material.dart';
import 'package:schedule_ui/presentation/screen/splashScreen.dart';
import 'package:schedule_ui/presentation/screen/login.dart';
import 'package:schedule_ui/presentation/screen/forgot_password.dart';
import 'package:schedule_ui/presentation/screen/reset_password.dart';
import 'package:schedule_ui/presentation/screen/admin/admin_dashboard.dart';
import 'package:schedule_ui/presentation/screen/teacher/teacher_dashboard.dart';
import 'package:schedule_ui/presentation/screen/student/student_dashboard.dart';
import 'package:schedule_ui/data/model/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
        '/admin': (_) => AdminDashboard(user: UserModel(
          id: 0,
          username: '',
          email: '',
          role: 0, // Admin
        )),
        '/teacher': (_) => TeacherDashboard(user: UserModel(
          id: 0,
          username: '',
          email: '',
          role: 1, // Teacher
        )),
        '/student': (_) => StudentDashboard(user: UserModel(
          id: 0,
          username: '',
          email: '',
          role: 2, // Student
        )),
      },
    );
  }
}




