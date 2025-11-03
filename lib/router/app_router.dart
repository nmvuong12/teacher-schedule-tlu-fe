// [app_router.dart] - ĐÃ SỬA LỖI
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../presentation/controller/app_controller.dart';
import '../presentation/screen/admin/leave_request_management.dart';
import '../presentation/screen/admin/statistics_screen.dart';
import '../presentation/screen/login.dart';
import '../presentation/screen/splashScreen.dart';
import '../core/api_service/session_manager.dart';
import '../data/model/user_model.dart';

// Admin Screens
import '../presentation/screen/admin/dashboard_overview.dart';
import '../presentation/screen/admin/course_management.dart';
import '../presentation/screen/admin/user_management.dart';
import '../presentation/screen/admin/class_management.dart';
import '../presentation/screen/admin/subject_management.dart';
import '../presentation/screen/admin/teacher_management.dart';
import '../presentation/screen/admin/student_management.dart';
import '../presentation/screen/admin/session_management.dart';

// Dashboards (Non-Admin)
// [LƯU Ý]: Tên file là 'teacher_main_screen.dart'
import '../presentation/screen/teacher/teacher_main_screen.dart';
import '../presentation/screen/student/student_dashboard.dart';

// Widgets
import '../presentation/widget/admin_sidebar.dart';
import '../presentation/widget/admin_header.dart';

class AppRouter {
  // Public Routes
  static const String splash = '/';
  static const String login = '/login';

  // Admin Routes
  static const String dashboard = '/dashboard';
  static const String courses = '/courses';
  static const String leaveRequests = '/leave-requests';
  static const String statistics = '/statistics';
  static const String users = '/users';
  static const String classes = '/classes';
  static const String subjects = '/subjects';
  static const String teachers = '/teachers';
  static const String students = '/students';
  static const String sessions = '/sessions';

  // Other User Routes
  static const String teacherDashboard = '/teacher';
  static const String studentDashboard = '/student';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    redirect: (context, state) async {
      // (Phần redirect của bạn đã ổn, giữ nguyên)
      final (token, user) = await SessionManager.loadSession();
      final bool isLoggedIn = token != null && user != null;

      final bool isPublicRoute =
          state.uri.path == splash || state.uri.path == login;

      if (isPublicRoute) {
        if (isLoggedIn && state.uri.path == login) {
          switch (user.role) {
            case 0:
              return dashboard;
            case 1:
              return teacherDashboard;
            case 2:
              return studentDashboard;
            default:
              return login;
          }
        }
        return null;
      }
      if (!isPublicRoute && !isLoggedIn) {
        return login;
      }
      return null;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Login screen
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // [SỬA LẠI] Teacher Dashboard Route
      GoRoute(
        path: teacherDashboard,
        name: 'teacher',
        builder: (context, state) {
          // 1. Ưu tiên lấy user từ 'extra' (được truyền khi điều hướng)
          UserModel? user = state.extra as UserModel?;

          // 2. Nếu 'extra' rỗng (VD: người dùng F5 trình duyệt),
          //    thử lấy từ AppController (đã được splash screen set)
          user ??= Provider.of<AppController>(context, listen: false).currentUser;

          // 3. Nếu cả hai đều rỗng, dùng 'Guest' (dự phòng cuối cùng)

          // [SỬA LỖI] - Tên lớp phải là 'TeacherMainScreen'
          // để khớp với file import (dòng 27)
          return TeacherMainScreen(
              user: user ??
                  UserModel(
                      id: 0, username: 'Guest', email: '', role: 1));
        },
      ),

      // [SỬA LẠI] Student Dashboard Route
      GoRoute(
        path: studentDashboard,
        name: 'student',
        builder: (context, state) {
          // 1. Ưu tiên lấy user từ 'extra'
          UserModel? user = state.extra as UserModel?;

          // 2. Nếu 'extra' rỗng, thử lấy từ AppController
          user ??= Provider.of<AppController>(context, listen: false).currentUser;

          // 3. Nếu cả hai đều rỗng, dùng 'Guest'
          return StudentDashboard(
              user: user ??
                  UserModel(
                      id: 0, username: 'Guest', email: '', role: 2));
        },
      ),

      // Protected Admin Routes (giữ nguyên)
      ShellRoute(
        builder: (context, state, child) {
          return AdminDashboardWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardOverview(),
          ),
          GoRoute(
            path: courses,
            name: 'courses',
            builder: (context, state) => const CourseManagement(),
          ),
          GoRoute(
            path: leaveRequests,
            name: 'leave-requests',
            builder: (context, state) => const LeaveRequestManagement(),
          ),
          GoRoute(
            path: statistics,
            name: 'statistics',
            builder: (context, state) => const StatisticsScreen(),
          ),
          GoRoute(
            path: users,
            name: 'users',
            builder: (context, state) => const UserManagement(),
          ),
          GoRoute(
            path: classes,
            name: 'classes',
            builder: (context, state) => const ClassManagement(),
          ),
          GoRoute(
            path: subjects,
            name: 'subjects',
            builder: (context, state) => const SubjectManagement(),
          ),
          GoRoute(
            path: teachers,
            name: 'teachers',
            builder: (context, state) => const TeacherManagement(),
          ),
          GoRoute(
            path: students,
            name: 'students',
            builder: (context, state) => const StudentManagement(),
          ),
          GoRoute(
            path: sessions,
            name: 'sessions',
            builder: (context, state) => const SessionManagement(),
          ),
        ],
      ),
    ],
  );
}

// -----------------------------------------------------------------
// Lớp Wrapper cho Admin Dashboard (giữ nguyên)
// -----------------------------------------------------------------
class AdminDashboardWrapper extends StatefulWidget {
  final Widget child;

  const AdminDashboardWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AdminDashboardWrapper> createState() => _AdminDashboardWrapperState();
}

class _AdminDashboardWrapperState extends State<AdminDashboardWrapper> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize data when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Sửa lại: Chỉ initialize nếu là admin
      final user = context.read<AppController>().currentUser;
      if (user != null && user.role == 0) {
        context.read<AppController>().initialize();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update selected index based on current route
    final location = GoRouterState.of(context).uri.path;
    _updateSelectedIndex(location);
  }

  void _updateSelectedIndex(String location) {
    int newIndex = 0;
    switch (location) {
      case AppRouter.dashboard:
        newIndex = 0;
        break;
      case AppRouter.courses:
        newIndex = 1;
        break;
      case AppRouter.sessions:
        newIndex = 2;
        break;
      case AppRouter.leaveRequests:
        newIndex = 3;
        break;
      case AppRouter.users:
        newIndex = 4;
        break;
      case AppRouter.classes:
        newIndex = 5;
        break;
      case AppRouter.students:
        newIndex = 6;
        break;
      case AppRouter.teachers:
        newIndex = 7;
        break;
      case AppRouter.subjects:
        newIndex = 8;
        break;
      case AppRouter.statistics:
        newIndex = 9;
        break;
    }

    if (newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AdminSidebar(
            selectedIndex: _selectedIndex,
            navigationItems: _getNavigationItems(),
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
              _navigateToRoute(index);
            },
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                const AdminHeader(),
                // Content
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<NavigationItem> _getNavigationItems() {
    return [
      NavigationItem(
        icon: Icons.home,
        title: 'Trang chủ',
        index: 0,
        route: AppRouter.dashboard,
      ),
      NavigationItem(
        icon: Icons.book,
        title: 'Quản lý học phần',
        index: 1,
        route: AppRouter.courses,
      ),
      NavigationItem(
        icon: Icons.event,
        title: 'Quản lý buổi học',
        index: 2,
        route: AppRouter.sessions,
      ),
      NavigationItem(
        icon: Icons.assignment,
        title: 'Quản lý đơn xin nghỉ',
        index: 3,
        route: AppRouter.leaveRequests,
      ),
      NavigationItem(
        icon: Icons.people,
        title: 'Quản lý người dùng',
        index: 4,
        route: AppRouter.users,
      ),
      NavigationItem(
        icon: Icons.school,
        title: 'Quản lý lớp học',
        index: 5,
        route: AppRouter.classes,
      ),
      NavigationItem(
        icon: Icons.person_outline,
        title: 'Quản lý sinh viên',
        index: 6,
        route: AppRouter.students,
      ),
      NavigationItem(
        icon: Icons.person,
        title: 'Quản lý giảng viên',
        index: 7,
        route: AppRouter.teachers,
      ),
      NavigationItem(
        icon: Icons.subject,
        title: 'Quản lý môn học',
        index: 8,
        route: AppRouter.subjects,
      ),
      NavigationItem(
        icon: Icons.bar_chart,
        title: 'Thống kê',
        index: 9,
        route: AppRouter.statistics,
      ),
    ];
  }

  void _navigateToRoute(int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.dashboard);
        break;
      case 1:
        context.go(AppRouter.courses);
        break;
      case 2:
        context.go(AppRouter.sessions);
        break;
      case 3:
        context.go(AppRouter.leaveRequests);
        break;
      case 4:
        context.go(AppRouter.users);
        break;
      case 5:
        context.go(AppRouter.classes);
        break;
      case 6:
        context.go(AppRouter.students);
        break;
      case 7:
        context.go(AppRouter.teachers);
        break;
      case 8:
        context.go(AppRouter.subjects);
        break;
      case 9:
        context.go(AppRouter.statistics);
        break;
    }
  }
}

// -----------------------------------------------------------------
// Lớp NavigationItem (giữ nguyên)
// -----------------------------------------------------------------
class NavigationItem {
  final IconData icon;
  final String title;
  final int index;
  final String route;

  NavigationItem({
    required this.icon,
    required this.title,
    required this.index,
    required this.route,
  });
}