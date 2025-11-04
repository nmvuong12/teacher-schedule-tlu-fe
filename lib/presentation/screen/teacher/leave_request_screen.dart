import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/repo/teaching_leave_repository.dart';
import '../../../data/model/teaching_leave_dto.dart';
import 'leave_success_screen.dart';

class LeaveRequestScreen extends StatefulWidget {
  static const String routeName = '/leave-request';
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final TextEditingController reasonController = TextEditingController();
  final TeachingLeaveRepository _repo = TeachingLeaveRepository();
  DateTime? plannedDate;
  bool submitting = false;
  TeachingLeaveDto? existingLeave;
  bool isLoadingExisting = true;

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Dismiss tất cả SnackBar cũ khi mở màn hình mới
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).clearSnackBars();
    });
    // Load dữ liệu cũ trong background, không chặn UI
    _loadExistingLeave();
  }

  Future<void> _loadExistingLeave() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map && args['sessionId'] != null) {
      try {
        final sessionId = args['sessionId'] as int;
        final existing = await _repo.getBySessionId(sessionId);
        if (mounted) {
          setState(() {
            existingLeave = existing;
            isLoadingExisting = false;
            // Nếu đã có yêu cầu, load dữ liệu vào form
            if (existing != null) {
              reasonController.text = existing.reason;
              try {
                final dateParts = existing.expectedMakeupDate.split('-');
                if (dateParts.length == 3) {
                  plannedDate = DateTime(
                    int.parse(dateParts[0]),
                    int.parse(dateParts[1]),
                    int.parse(dateParts[2]),
                  );
                }
              } catch (e) {
                // Ignore date parse error
              }
            }
          });
        }
      } catch (e) {
        // Ignore error, không hiển thị loading nữa
        if (mounted) {
          setState(() {
            isLoadingExisting = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          isLoadingExisting = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != plannedDate) {
      setState(() {
        plannedDate = picked;
      });
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập lý do nghỉ dạy')),
      );
      return;
    }

    if (plannedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày bù dự kiến')),
      );
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Map || args['sessionId'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thiếu thông tin buổi học')),
      );
      return;
    }

    setState(() {
      submitting = true;
    });

    try {
      final sessionId = args['sessionId'] as int;

      final dto = TeachingLeaveDto(
        sessionId: sessionId,
        reason: reasonController.text.trim(),
        expectedMakeupDate: DateFormat('yyyy-MM-dd').format(plannedDate!),
        status: existingLeave?.status ?? 0, // Giữ nguyên status nếu đã có
      );

      // Nếu đã có yêu cầu, cập nhật; nếu chưa có, tạo mới
      if (existingLeave != null) {
        await _repo.update(sessionId, dto);
      } else {
        await _repo.create(dto);
      }

      if (mounted) {
        // Chuyển sang màn hình thành công
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LeaveSuccessScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        // Parse error message to show user-friendly message
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          errorMessage = errorMessage.replaceFirst('Exception: ', '');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Đóng',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
        setState(() {
          submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String title = 'Buổi học';
    String? subjectName;
    
    if (args is Map) {
      if (args['title'] is String) {
        title = args['title'] as String;
      }
      if (args['subjectName'] is String) {
        subjectName = args['subjectName'] as String;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký nghỉ dạy'),
        backgroundColor: const Color(0xFF3A5BA0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị thông báo nếu đã có yêu cầu (sẽ hiển thị sau khi load xong)
            if (existingLeave != null && !isLoadingExisting)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Buổi học này đã có yêu cầu nghỉ dạy. Bạn có thể cập nhật thông tin bên dưới.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Tên buổi học
            const Text(
              'Tên buổi học',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lý do nghỉ dạy',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Nhập lý do nghỉ dạy...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ngày dạy bù dự kiến',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  suffixIcon: Icon(Icons.calendar_today, color: const Color(0xFF3A5BA0)),
                ),
                child: Text(
                  plannedDate != null
                      ? DateFormat('dd/MM/yyyy').format(plannedDate!)
                      : 'Chọn ngày nghỉ dạy',
                  style: TextStyle(
                    color: plannedDate != null ? Colors.black87 : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // 2 nút: Quay lại và Gửi yêu cầu
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: submitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade400),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Quay lại', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: submitting ? null : _submitLeaveRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            existingLeave != null ? 'Cập nhật yêu cầu' : 'Gửi yêu cầu',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

