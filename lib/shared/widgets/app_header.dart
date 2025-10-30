import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppHeader extends StatelessWidget {
  final String userRole;
  final String userName;
  final VoidCallback? onLogout;
  final String? searchHint;
  final Function(String)? onSearchChanged;
  final VoidCallback? onNotificationPressed;

  const AppHeader({
    super.key,
    required this.userRole,
    required this.userName,
    this.onLogout,
    this.searchHint,
    this.onSearchChanged,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // Title
            Expanded(
              child: Text(
                'Hệ thống quản lý lịch trình giảng dạy',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),
            
            // Search bar (optional)
            if (searchHint != null)
              Container(
                width: 300,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: searchHint,
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            
            if (searchHint != null) const SizedBox(width: 16),
            
            // Notifications (optional)
            if (onNotificationPressed != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.bell,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  onPressed: onNotificationPressed,
                ),
              ),
            
            if (onNotificationPressed != null) const SizedBox(width: 12),
            
            // User info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.user,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userRole,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Logout button
            if (onLogout != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.rightFromBracket,
                    size: 16,
                    color: Colors.red[600],
                  ),
                  onPressed: onLogout,
                  tooltip: 'Đăng xuất',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
