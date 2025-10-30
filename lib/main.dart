import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/controller/app_controller.dart';
import 'router/app_router.dart';
import 'presentation/screen/splashScreen.dart';
import 'presentation/screen/login.dart';
import 'presentation/screen/forgot_password.dart';
import 'presentation/screen/reset_password.dart';
import 'presentation/screen/admin/admin_dashboard.dart';
import 'presentation/screen/teacher/teacher_dashboard.dart';
import 'presentation/screen/student/student_dashboard.dart';
import 'data/model/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppController(),
      child: Builder(
        builder: (context) {
          // ⚙️ Nếu đang chạy web → vào router-based (code mới)
          if (kIsWeb) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Hệ thống quản lý lịch trình giảng dạy',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                primaryColor: const Color(0xFF1E3A8A),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF1E3A8A),
                  primary: const Color(0xFF1E3A8A),
                ),
                useMaterial3: true,
                fontFamily: 'Roboto',
              ),
              routerConfig: AppRouter.router,
            );
          }

          // 📱 Nếu là mobile → dùng routes truyền thống
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Hệ thống quản lý lịch trình giảng dạy',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Roboto',
            ),
            home: const SplashScreen(),
            routes: {
              '/login': (_) => const LoginScreen(),
              '/forgot-password': (_) => const ForgotPasswordScreen(),
              '/reset-password': (_) => const ResetPasswordScreen(),
              '/admin': (_) => AdminDashboard(
                user: UserModel(
                  id: 0,
                  username: '',
                  email: '',
                  role: 0,
                ),
              ),
              '/teacher': (_) => TeacherDashboard(
                user: UserModel(
                  id: 0,
                  username: '',
                  email: '',
                  role: 1,
                ),
              ),
              '/student': (_) => StudentDashboard(
                user: UserModel(
                  id: 0,
                  username: '',
                  email: '',
                  role: 2,
                ),
              ),
            },
          );
        },
      ),
    );
  }
}
