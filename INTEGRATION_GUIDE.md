# 🔐 Hướng dẫn tích hợp chức năng đăng xuất

## 📋 Tổng quan

File này hướng dẫn cách tích hợp chức năng đăng xuất vào Teacher Dashboard và Student Dashboard. Chức năng đăng xuất đã được implement sẵn và có thể tái sử dụng cho tất cả các role.

## ✅ Những gì đã có sẵn

### 1. SessionManager với chức năng logout
```dart
// lib/core/api_service/session_manager.dart
static Future<void> logout() async {
  await clearSession();
  // Có thể thêm logic khác như gọi API logout nếu cần
}
```

### 2. Shared AppHeader component
```dart
// lib/shared/widgets/app_header.dart
class AppHeader extends StatelessWidget {
  final String userRole;
  final String userName;
  final VoidCallback? onLogout;
  // ... các thuộc tính khác
}
```

### 3. AppRouter với route login
```dart
// lib/router/app_router.dart
static const String login = '/login';
static const String dashboard = '/dashboard';
```

## 🚀 Cách tích hợp

### Bước 1: Import các dependencies cần thiết

Thêm vào đầu file dashboard của bạn:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schedule_ui/shared/widgets/app_header.dart';
import 'package:schedule_ui/core/api_service/session_manager.dart';
import 'package:schedule_ui/router/app_router.dart';
```

### Bước 2: Tạo function logout

Thêm function này vào class dashboard của bạn:

```dart
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
```

### Bước 3: Thay thế header hiện tại

#### Cho Teacher Dashboard:
```dart
// Thay thế header cũ bằng:
AppHeader(
  userRole: 'Giảng viên',
  userName: 'Tên giảng viên', // Có thể lấy từ user data
  searchHint: 'Tìm kiếm lịch dạy...',
  onSearchChanged: (value) {
    // Handle search functionality
    print('Teacher Search: $value');
  },
  onNotificationPressed: () {
    // Handle notifications
    print('Teacher notifications pressed');
  },
  onLogout: _handleLogout,
)
```

#### Cho Student Dashboard:
```dart
// Thay thế header cũ bằng:
AppHeader(
  userRole: 'Sinh viên',
  userName: 'Tên sinh viên', // Có thể lấy từ user data
  searchHint: 'Tìm kiếm lịch học...',
  onSearchChanged: (value) {
    // Handle search functionality
    print('Student Search: $value');
  },
  onNotificationPressed: () {
    // Handle notifications
    print('Student notifications pressed');
  },
  onLogout: _handleLogout,
)
```

## 🎨 Tùy chỉnh giao diện

### Thay đổi màu sắc:
```dart
AppHeader(
  userRole: 'Giảng viên',
  userName: 'Tên giảng viên',
  // Có thể thêm các thuộc tính tùy chỉnh khác
  onLogout: _handleLogout,
)
```

### Ẩn/hiện các thành phần:
```dart
AppHeader(
  userRole: 'Sinh viên',
  userName: 'Tên sinh viên',
  searchHint: null, // Ẩn search bar
  onNotificationPressed: null, // Ẩn notification
  onLogout: _handleLogout,
)
```

## 📱 Ví dụ hoàn chỉnh

### Teacher Dashboard:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schedule_ui/shared/widgets/app_header.dart';
import 'package:schedule_ui/core/api_service/session_manager.dart';
import 'package:schedule_ui/router/app_router.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  Future<void> _handleLogout() async {
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
    return Scaffold(
      body: Column(
        children: [
          // Header với chức năng đăng xuất
          AppHeader(
            userRole: 'Giảng viên',
            userName: 'Tên giảng viên',
            searchHint: 'Tìm kiếm lịch dạy...',
            onSearchChanged: (value) {
              // Handle search
            },
            onNotificationPressed: () {
              // Handle notifications
            },
            onLogout: _handleLogout,
          ),
          // Nội dung dashboard
          Expanded(
            child: Container(
              // ... nội dung dashboard của bạn
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🔧 Troubleshooting

### Lỗi import:
- Đảm bảo đã pull code mới nhất
- Kiểm tra đường dẫn import có đúng không

### Lỗi routing:
- Đảm bảo đã import `go_router`
- Kiểm tra `AppRouter.login` có tồn tại không

### UI không hiển thị:
- Kiểm tra `AppHeader` có được wrap đúng cách không
- Đảm bảo `Scaffold` có `body` chứa `Column` với `AppHeader`

## 📞 Hỗ trợ

Nếu gặp vấn đề gì, hãy liên hệ để được hỗ trợ!

---

**Lưu ý**: File này được tạo tự động, nếu có thay đổi gì trong code base, hãy cập nhật file này cho phù hợp.
