import 'package:flutter/material.dart';
import 'package:schedule_ui/shared/widgets/app_header.dart';
import 'package:schedule_ui/core/api_service/session_manager.dart';

class TeacherHeader extends StatelessWidget {
  const TeacherHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      userRole: 'Giảng viên',
      userName: 'Teacher Name',
      searchHint: 'Tìm kiếm lịch dạy...',
      onSearchChanged: (value) {
        // Handle search functionality for teacher
        print('Teacher Search: $value');
      },
      onNotificationPressed: () {
        // Handle notifications for teacher
        print('Teacher notifications pressed');
      },
      onLogout: () async {
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
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        }
      },
    );
  }
}
