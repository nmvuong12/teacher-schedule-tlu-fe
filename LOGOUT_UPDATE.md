# 🔐 Cập nhật: Chức năng đăng xuất

## 📦 Những gì mới

### ✅ Đã thêm:
- **SessionManager.logout()** - Function đăng xuất
- **AppHeader component** - Header tái sử dụng cho tất cả role
- **AdminHeader** - Đã có sẵn chức năng đăng xuất

### 📁 Files mới:
- `lib/shared/widgets/app_header.dart` - Shared header component
- `lib/presentation/widget/teacher_header.dart` - Template cho teacher
- `lib/presentation/widget/student_header.dart` - Template cho student

### 📚 Files hướng dẫn:
- `INTEGRATION_GUIDE.md` - Hướng dẫn chi tiết
- `LOGOUT_TEMPLATE.dart` - Code template để copy-paste

## 🚀 Cách sử dụng

### Cho Teacher Dashboard:
1. Import các dependencies cần thiết
2. Copy function `_handleLogout()` 
3. Thay thế header cũ bằng `AppHeader` với config teacher
4. Done! ✨

### Cho Student Dashboard:
1. Import các dependencies cần thiết  
2. Copy function `_handleLogout()`
3. Thay thế header cũ bằng `AppHeader` với config student
4. Done! ✨

## 📖 Chi tiết

Xem file `INTEGRATION_GUIDE.md` để biết cách tích hợp chi tiết.

Xem file `LOGOUT_TEMPLATE.dart` để copy code nhanh.

---

**Lưu ý**: Chức năng này hoàn toàn tái sử dụng được và không ảnh hưởng đến code hiện tại của bạn.
