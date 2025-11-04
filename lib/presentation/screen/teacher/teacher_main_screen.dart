import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schedule_ui/presentation/screen/teacher/teacher_schedule_screen.dart';
import '../../../core/api_service/session_manager.dart';
import '../../../data/model/user_model.dart';
import '../../../router/app_router.dart';
import 'teacher_profile_screen.dart';
import 'teacher_home_screen.dart';
import 'teacher_courses_screen.dart';

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final (_, userJson) = await SessionManager.loadSession();
    if (userJson != null) {
      print('🔍 TeacherMainScreen: Loading user from session');
      print('📦 userJson: $userJson');
      print('📦 teacherId in userJson: ${userJson['teacherId']}');
      setState(() {
        _user = UserModel.fromJson(userJson);
        print('📦 UserModel loaded - teacherId: ${_user?.teacherId}');
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await SessionManager.logout();
      if (mounted) {
        context.go(AppRouter.login);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF3A5BA0),
          title: const Text(
            'TLU Schedule',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: const Center(child: Text('Không tìm thấy thông tin người dùng')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A5BA0),
        title: const Text(
          'TLU Schedule',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
            tooltip: 'Đăng xuất',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFA726),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Hôm nay'),
            Tab(text: 'Lịch dạy'),
            Tab(text: 'Học phần'),
            Tab(text: 'Thông tin'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TeacherHomeScreen(key: const ValueKey('tab_today'), user: _user!),
          const TeacherScheduleScreen(key: ValueKey('tab_schedule')),
          TeacherCoursesScreen(key: const ValueKey('tab_subject'), user: _user!),
          TeacherProfileScreen(key: const ValueKey('tab_profile')),
        ],
      ),
    );
  }
}