# Hệ thống quản lý lịch trình giảng dạy - Admin UI

Giao diện web admin cho hệ thống quản lý lịch trình giảng dạy, được xây dựng bằng Flutter Web và tích hợp với Spring Boot backend.

## 🚀 Tính năng chính

### 1. Dashboard Overview
- **Tổng quan thống kê**: Hiển thị tổng số học phần, giảng viên, đơn xin nghỉ chờ duyệt, cảnh báo tiến độ
- **Buổi học hôm nay**: Danh sách các buổi học trong ngày
- **Đơn xin nghỉ gần đây**: Các đơn xin nghỉ mới nhất
- **Truy cập trực tiếp**: Không cần đăng nhập, mở trực tiếp dashboard admin
- **URL Routing**: Mỗi màn hình có URL riêng, hỗ trợ bookmark và browser navigation

### 2. Quản lý học phần
- **CRUD operations**: Thêm, sửa, xóa học phần
- **Tìm kiếm và lọc**: Tìm kiếm theo tên học phần, lớp, giảng viên
- **Bảng dữ liệu**: Hiển thị thông tin chi tiết với phân trang
- **Trạng thái**: Theo dõi trạng thái học phần (Chưa bắt đầu, Đang diễn ra, Kết thúc)

### 3. Quản lý đơn xin nghỉ
- **Duyệt đơn**: Phê duyệt hoặc từ chối đơn xin nghỉ
- **Lọc theo trạng thái**: Chờ duyệt, Đã phê duyệt, Từ chối
- **Thông tin chi tiết**: Giảng viên, học phần, ngày nghỉ, ngày dạy bù, lý do

### 4. Thống kê
- **Biểu đồ tròn**: Phân bố học phần theo trạng thái
- **Biểu đồ cột**: Thống kê đơn xin nghỉ theo trạng thái
- **Biểu đồ đường**: Thống kê theo tháng
- **Bảng chi tiết**: Các chỉ số quan trọng với xu hướng thay đổi

## 🛠️ Công nghệ sử dụng

- **Frontend**: Flutter Web
- **State Management**: Provider
- **Routing**: go_router
- **HTTP Client**: http package
- **Charts**: fl_chart
- **Icons**: font_awesome_flutter
- **Data Tables**: data_table_2
- **Backend**: Spring Boot (schedule-service)

## 📦 Cài đặt và chạy

### Yêu cầu hệ thống
- Flutter SDK 3.9.2+
- Dart 3.0+
- Web browser (Chrome, Firefox, Safari, Edge)

### Cài đặt dependencies
```bash
flutter pub get
