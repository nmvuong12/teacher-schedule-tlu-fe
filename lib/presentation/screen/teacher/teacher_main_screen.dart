import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Thêm import cho go_router
import '../../../data/model/user_model.dart';
// import '../login.dart'; // Xóa import LoginScreen cũ
import '../../../core/api_service/session_manager.dart';
import '/router/app_router.dart'; // Thêm import cho AppRouter
import 'teacher_courses_screen.dart';
import 'teacher_home_screen.dart';
import 'teacher_profile_screen.dart';

// Chuyển thành StatefulWidget
class TeacherMainScreen extends StatefulWidget {
  final UserModel user;

  const TeacherMainScreen({super.key, required this.user});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  // Thêm hàm _handleLogout từ file hướng dẫn
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await SessionManager.logout(); // Dùng hàm logout() mới
      if (mounted) {
        context.go(AppRouter.login); // Dùng go_router để điều hướng
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3B5998),
          title: const Text(
            "TLU Schedule",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              // Cập nhật onPressed để gọi hàm _handleLogout
              onPressed: _handleLogout,
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.yellow,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.yellow,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Hôm nay"),
              Tab(text: "Lịch dạy"),
              Tab(text: "Học phần"),
              Tab(text: "Thông tin"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Truy cập user qua `widget.user`
            TeacherHomeScreen(user: widget.user),
            const Center(child: Text("Màn hình Lịch dạy (chưa làm)")),
            TeacherCoursesScreen(user: widget.user),
            TeacherProfileScreen(user: widget.user),
          ],
        ),
      ),
    );
  }
}