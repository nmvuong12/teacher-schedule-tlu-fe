import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../controller/app_controller.dart';
import '../../widget/statistics_chart.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, child) {
        return Container(
          color: Colors.grey[50],
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Thống kê',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Overview cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Tổng số học phần',
                        controller.totalCourses.toString(),
                        FontAwesomeIcons.book,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Tổng số giảng viên',
                        controller.totalTeachers.toString(),
                        FontAwesomeIcons.users,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Đơn xin nghỉ chờ duyệt',
                        controller.pendingLeaveRequests.toString(),
                        FontAwesomeIcons.clipboardList,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Buổi học hôm nay',
                        controller.todaySessions.length.toString(),
                        FontAwesomeIcons.calendarDay,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Charts
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course sections by status
                    Expanded(
                      child: StatisticsChart(
                        title: 'Học phần theo trạng thái',
                        chartType: ChartType.pie,
                        data: _getCourseStatusData(controller),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Teaching leaves by status
                    Expanded(
                      child: StatisticsChart(
                        title: 'Đơn xin nghỉ theo trạng thái',
                        chartType: ChartType.bar,
                        data: _getLeaveStatusData(controller),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Monthly statistics
                Row(
                  children: [
                    Expanded(
                      child: StatisticsChart(
                        title: 'Thống kê theo tháng',
                        chartType: ChartType.line,
                        data: _getMonthlyData(controller),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatisticsChart(
                        title: 'Phân bố giảng viên theo bộ môn',
                        chartType: ChartType.bar,
                        data: _getDepartmentData(controller),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Detailed statistics table
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chi tiết thống kê',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatisticsTable(controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FaIcon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTable(AppController controller) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Chỉ số')),
        DataColumn(label: Text('Giá trị')),
        DataColumn(label: Text('Thay đổi')),
      ],
      rows: [
        DataRow(cells: [
          const DataCell(Text('Tổng số học phần')),
          DataCell(Text(controller.totalCourses.toString())),
          const DataCell(Text('+5%', style: TextStyle(color: Colors.green))),
        ]),
        DataRow(cells: [
          const DataCell(Text('Tổng số giảng viên')),
          DataCell(Text(controller.totalTeachers.toString())),
          const DataCell(Text('+2%', style: TextStyle(color: Colors.green))),
        ]),
        DataRow(cells: [
          const DataCell(Text('Đơn xin nghỉ chờ duyệt')),
          DataCell(Text(controller.pendingLeaveRequests.toString())),
          const DataCell(Text('-10%', style: TextStyle(color: Colors.red))),
        ]),
        DataRow(cells: [
          const DataCell(Text('Buổi học hôm nay')),
          DataCell(Text(controller.todaySessions.length.toString())),
          const DataCell(Text('+15%', style: TextStyle(color: Colors.green))),
        ]),
        DataRow(cells: [
          const DataCell(Text('Tỷ lệ hoàn thành học phần')),
          const DataCell(Text('85%')),
          const DataCell(Text('+3%', style: TextStyle(color: Colors.green))),
        ]),
      ],
    );
  }

  Map<String, double> _getCourseStatusData(AppController controller) {
    final courses = controller.courseSections;
    final ongoing = courses.where((c) => c.status == 'Đang diễn ra').length;
    final notStarted = courses.where((c) => c.status == 'Chưa bắt đầu').length;
    final finished = courses.where((c) => c.status == 'Kết thúc').length;
    
    return {
      'Đang diễn ra': ongoing.toDouble(),
      'Chưa bắt đầu': notStarted.toDouble(),
      'Kết thúc': finished.toDouble(),
    };
  }

  Map<String, double> _getLeaveStatusData(AppController controller) {
    final leaves = controller.teachingLeaves;
    final pending = leaves.where((l) => l.status == 0).length;
    final approved = leaves.where((l) => l.status == 1).length;
    final rejected = leaves.where((l) => l.status == 2).length;
    
    return {
      'Chờ duyệt': pending.toDouble(),
      'Đã phê duyệt': approved.toDouble(),
      'Từ chối': rejected.toDouble(),
    };
  }

  Map<String, double> _getMonthlyData(AppController controller) {
    // Mock data for monthly statistics
    return {
      'Tháng 1': 45.0,
      'Tháng 2': 52.0,
      'Tháng 3': 48.0,
      'Tháng 4': 61.0,
      'Tháng 5': 55.0,
      'Tháng 6': 67.0,
    };
  }

  Map<String, double> _getDepartmentData(AppController controller) {
    // Mock data for department distribution
    return {
      'CNTT': 25.0,
      'Toán': 18.0,
      'Vật Lý': 15.0,
      'Hóa học': 12.0,
      'Khác': 8.0,
    };
  }
}
