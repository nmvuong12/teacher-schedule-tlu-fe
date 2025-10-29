import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../controller/app_controller.dart';
import '../../widget/stat_card.dart';
import '../../widget/today_sessions_card.dart';
import '../../widget/recent_leaves_card.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

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
                  'Tổng quan',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Statistics cards
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: FontAwesomeIcons.book,
                        title: 'Tổng số học phần',
                        value: controller.totalCourses.toString(),
                        color: Colors.blue,
                        onTap: () {
                          context.go(AppRouter.courses);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        icon: FontAwesomeIcons.users,
                        title: 'Giảng viên',
                        value: controller.totalTeachers.toString(),
                        color: Colors.green,
                        onTap: () {
                          context.go(AppRouter.teachers);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        icon: FontAwesomeIcons.clipboardList,
                        title: 'Đơn xin nghỉ chờ',
                        value: controller.pendingLeaveRequests.toString(),
                        color: Colors.orange,
                        onTap: () {
                          context.go(AppRouter.leaveRequests);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        icon: FontAwesomeIcons.exclamationTriangle,
                        title: 'Cảnh báo tiến độ',
                        value: controller.progressWarnings.toString(),
                        color: Colors.red,
                        onTap: () {
                          context.go(AppRouter.statistics);
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Today's classes and Recent leave requests
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's classes
                    Expanded(
                      child: TodaySessionsCard(
                        sessions: controller.todaySessions,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Recent leave requests
                    Expanded(
                      child: RecentLeavesCard(
                        leaves: controller.recentLeaveRequests,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
