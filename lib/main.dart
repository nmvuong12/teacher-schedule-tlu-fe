import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/controller/app_controller.dart';
import 'router/app_router.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- 1. THÊM DÒNG NÀY

Future<void> main() async { // <-- 2. SỬA 'void' THÀNH 'Future<void> async'

  // 3. THÊM 2 DÒNG NÀY
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null); // Khởi tạo locale tiếng Việt

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppController(),
      child: MaterialApp.router(
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
      ),
    );
  }
}