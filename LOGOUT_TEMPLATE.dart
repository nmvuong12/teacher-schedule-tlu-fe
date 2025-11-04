// ========================================
// 🔐 TEMPLATE CODE CHO CHỨC NĂNG ĐĂNG XUẤT
// ========================================
// Copy code này vào dashboard của bạn

// 1. IMPORTS CẦN THIẾT
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schedule_ui/shared/widgets/app_header.dart';
import 'package:schedule_ui/core/api_service/session_manager.dart';
import 'package:schedule_ui/router/app_router.dart';

// 2. FUNCTION LOGOUT - Copy vào class dashboard của bạn
// LƯU Ý: Đây là template code, cần copy vào trong một StatefulWidget hoặc StatelessWidget
// để có thể sử dụng 'context' và 'mounted' (nếu là StatefulWidget)

// Ví dụ cho StatefulWidget:
/*
class YourDashboard extends StatefulWidget {
  @override
  State<YourDashboard> createState() => _YourDashboardState();
}

class _YourDashboardState extends State<YourDashboard> {
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
      await SessionManager.logout();
      if (mounted) {
        context.go(AppRouter.login);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Your widget code here
    return Container();
  }
}
*/

// Ví dụ cho StatelessWidget:
/*
class YourDashboard extends StatelessWidget {
  Future<void> _handleLogout(BuildContext context) async {
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
      await SessionManager.logout();
      context.go(AppRouter.login);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Your widget code here
    return Container();
  }
}
*/

// 3. TEMPLATE CHO TEACHER DASHBOARD
// LƯU Ý: Đây là template code, cần copy vào trong một class Widget
/*
Widget buildTeacherHeader(BuildContext context, VoidCallback onLogout) {
  return AppHeader(
    userRole: 'Giảng viên',
    userName: 'Tên giảng viên', // Thay bằng tên thật
    searchHint: 'Tìm kiếm lịch dạy...',
    onSearchChanged: (value) {
      // TODO: Implement search functionality
      print('Teacher Search: $value');
    },
    onNotificationPressed: () {
      // TODO: Implement notification functionality
      print('Teacher notifications pressed');
    },
    onLogout: onLogout,
  );
}
*/

// 4. TEMPLATE CHO STUDENT DASHBOARD
// LƯU Ý: Đây là template code, cần copy vào trong một class Widget
/*
Widget buildStudentHeader(BuildContext context, VoidCallback onLogout) {
  return AppHeader(
    userRole: 'Sinh viên',
    userName: 'Tên sinh viên', // Thay bằng tên thật
    searchHint: 'Tìm kiếm lịch học...',
    onSearchChanged: (value) {
      // TODO: Implement search functionality
      print('Student Search: $value');
    },
    onNotificationPressed: () {
      // TODO: Implement notification functionality
      print('Student notifications pressed');
    },
    onLogout: onLogout,
  );
}
*/

// 5. CÁCH SỬ DỤNG TRONG BUILD METHOD
// LƯU Ý: Đây là template code, cần copy vào trong một class Widget
/*
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        // Thay thế header cũ bằng một trong hai template trên
        buildTeacherHeader(context, _handleLogout), // hoặc buildStudentHeader(context, _handleLogout)
        
        // Nội dung dashboard của bạn
        Expanded(
          child: Container(
            // ... nội dung dashboard hiện tại
          ),
        ),
      ],
    ),
  );
}
*/

// ========================================
// 📝 HƯỚNG DẪN SỬ DỤNG:
// ========================================
// 1. Copy imports vào đầu file dashboard
// 2. Copy function _handleLogout() vào class dashboard
// 3. Copy template header phù hợp (teacher hoặc student)
// 4. Thay thế header cũ trong build() method
// 5. Customize userName và các thuộc tính khác nếu cần
// ========================================

