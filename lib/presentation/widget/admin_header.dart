import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schedule_ui/shared/widgets/app_header.dart';
import 'package:schedule_ui/core/api_service/session_manager.dart';
import 'package:schedule_ui/router/app_router.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key});

  @override
  Widget build(BuildContext context) {
              return AppHeader(
          userRole: 'Admin',
          userName: 'Admin User',
          searchHint: 'Tìm kiếm...',
              onSearchChanged: (value) {
          // Handle search functionality
          print('Search: $value');
    },
      onNotificationPressed: () {
        // Handle notifications
        print('Notifications pressed');
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
        context.go(AppRouter.login);
        }
        }
      },
    );
  }
}