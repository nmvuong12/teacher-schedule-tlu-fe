import 'package:flutter/material.dart';
import '../../../data/model/user_model.dart'; // Import UserModel

class TeacherProfileScreen extends StatelessWidget {
  // ✅ MỚI: Nhận thông tin user đã đăng nhập
  final UserModel user;

  const TeacherProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Thông tin cá nhân cơ bản
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF3B5998),
              child: Text(
                user.fullName?.substring(0, 1) ?? user.username.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              user.fullName ?? user.username,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              user.roleName,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const Divider(height: 40),

            // Các mục chi tiết
            _buildInfoCard(
              title: 'Thông tin liên hệ',
              icon: Icons.contact_mail,
              children: [
                _buildInfoRow('Email:', user.email),
                _buildInfoRow('Điện thoại:', user.phone ?? 'Chưa cập nhật'),
              ],
            ),
            _buildInfoCard(
              title: 'Thông tin công việc',
              icon: Icons.work,
              children: [
                _buildInfoRow('Phòng ban:', user.department ?? 'Chưa cập nhật'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF3B5998)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}