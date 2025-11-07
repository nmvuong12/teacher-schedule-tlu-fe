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
      final (token, userJson) = await SessionManager.loadSession();
      final bool isLoggedIn = token != null && userJson != null;

      final bool isPublicRoute =
          state.uri.path == splash || state.uri.path == login;

      if (isPublicRoute) {
        if (isLoggedIn && state.uri.path == login) {
// <<<<<<< HEAD
//           final userRole = userJson?['role'] as int? ?? 0;
//           switch (userRole) {
// =======
          // Ensure provider knows current user on direct access to /login
          final user = UserModel.fromJson(userJson);
          try {
            Provider.of<AppController>(context, listen: false).currentUser = user;
          } catch (_) {}
          switch (user.role) {
// >>>>>>> 57b66c4 (validate hoc phan, qli buoi hoc 4/11/25)
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
      // If accessing protected routes directly via URL or F5, set currentUser into provider
      if (!isPublicRoute && isLoggedIn) {
        try {
          final user = UserModel.fromJson(userJson);
          Provider.of<AppController>(context, listen: false).currentUser = user;
        } catch (_) {}
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
          // [SỬA LỖI] - Tên lớp phải là 'TeacherMainScreen'
          // để khớp với file import (dòng 27)
          return const TeacherMainScreen();
        },
      ),

      // [SỬA LẠI] Student Dashboard Route
      GoRoute(
        path: studentDashboard,
        name: 'student',
        builder: (context, state) {
          // 1. Ưu tiên lấy từ 'extra'
          final extra = state.extra as Map<String, dynamic>?;
          
          // 2. Nếu 'extra' rỗng, dùng giá trị mặc định
          final studentId = extra?['studentId'] as int? ?? 0;
          final studentName = extra?['studentName'] as String? ?? 'Guest';
          return StudentDashboard(
            studentId: studentId,
            studentName: studentName,
          );
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
  String? _lastRoute; // Track last route to detect route changes

  @override
  void initState() {
    super.initState();
    // Ensure currentUser is available when landing directly on a protected route (F5)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = context.read<AppController>();
      if (controller.currentUser == null) {
        final (token, userJson) = await SessionManager.loadSession();
        if (token != null && userJson != null) {
          final user = UserModel.fromJson(userJson);
          controller.currentUser = user;
          controller.refreshDataForRoute(GoRouterState.of(context).uri.path);
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update selected index based on current route
    final location = GoRouterState.of(context).uri.path;
    _updateSelectedIndex(location);

    // Load data only when route changes (not on initial load)
    if (_lastRoute != null && _lastRoute != location) {
      // Route changed, load data for this specific route
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final user = context.read<AppController>().currentUser;
        if (user != null && user.role == 0) {
          context.read<AppController>().refreshDataForRoute(location);
        }
      });
    } else if (_lastRoute == null) {
      // Initial load - load data for current route
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final user = context.read<AppController>().currentUser;
        if (user != null && user.role == 0) {
          context.read<AppController>().refreshDataForRoute(location);
        }
      });
    }
    _lastRoute = location;
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