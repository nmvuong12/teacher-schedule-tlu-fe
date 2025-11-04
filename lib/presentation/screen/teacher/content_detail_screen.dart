import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../data/model/session_model.dart';
import '../../../data/repo/session_repository.dart';

class ContentDetailScreen extends StatefulWidget {
  // 3. Accept sessionId to know which session to fetch
  final int sessionId;

  const ContentDetailScreen({super.key, required this.sessionId});

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  // 4. Declare state variables for managing API data
  final SessionRepository _repository = SessionRepository();
  late Future<Session> _sessionFuture;
  Session? _session; // Holds the session data after it's fetched

  PlatformFile? _pickedFile;
  final TextEditingController _contentController = TextEditingController();

  // Other state variables remain the same
  int _selectedIndex = 0;
  static const Color _primaryColor = Color(0xFF3B5998);
  static const Color _greenSaveButton = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    // 5. Fetch session data when the screen loads
    _sessionFuture = _repository.fetchSessionById(widget.sessionId);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // --- Dialog and helper methods ---
  // ... (Hàm _showFilePickerDialog giữ nguyên) ...
  Future<void> _showFilePickerDialog() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chọn tệp đính kèm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false);
                    if (result != null) {
                      setState(() {
                        _pickedFile = result.files.first;
                      });
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Chọn tệp từ thiết bị', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_pickedFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Tệp hiện tại: ${_pickedFile!.name}', style: const TextStyle(fontStyle: FontStyle.italic, color: _greenSaveButton), overflow: TextOverflow.ellipsis),
                ),
              const SizedBox(height: 20),
              const Text('Lưu ý: Chỉ chấp nhận các định dạng tài liệu phổ biến (PDF, DOCX, PPTX, ZIP).', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  // ... (Hàm _showStatusDialog giữ nguyên) ...
  Future<void> _showStatusDialog(String message, {bool isSuccess = true, bool shouldPop = false}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) {
            Navigator.of(context).pop();
            if (shouldPop && isSuccess) {
              // ✅ SỬA: Trả về 'true' khi pop để báo hiệu cho màn hình trước
              Navigator.pop(context, true);
            }
          }
        });
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: isSuccess ? _greenSaveButton : Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: isSuccess ? Colors.lightGreen.shade200 : Colors.red.shade200, width: 3),
                ),
                child: Icon(isSuccess ? Icons.check : Icons.close, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 15),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        );
      },
    );
  }

  // ✅✅✅ SỬA 1: SỬA HÀM NÀY ĐỂ NHẬN `valueColor` ✅✅✅
  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    const Color detailColor = Colors.black54;
    const double labelWidth = 70;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: detailColor),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Text(label, style: const TextStyle(fontWeight: FontWeight.normal, color: detailColor, fontSize: 13)),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      // Sửa ở đây: dùng valueColor thay vì isAlert
                      fontWeight: valueColor != null ? FontWeight.w600 : FontWeight.normal,
                      color: valueColor ?? Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ✅✅✅ KẾT THÚC SỬA 1 ✅✅✅

  // ... (Hàm _tabItem giữ nguyên) ...
  Widget _tabItem(String title, int index) {
    bool isSelected = _selectedIndex == index;
    const Color selectedColor = Colors.white;
    const Color unselectedColor = Colors.white70;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFFFFC107) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? selectedColor : unselectedColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // ✅ SỬA: Trả về 'false' (hoặc không gì) khi nhấn nút back
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text('TLU Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _tabItem('Hôm nay', 0),
              _tabItem('Lịch dạy', 1),
              // ================== SỬA: Thêm tab "Học phần" ==================
              _tabItem('Học phần', 2),
              _tabItem('Thông tin', 3), // Sửa index từ 2 -> 3
            ],
          ),
        ),
      ),
      body: FutureBuilder<Session>(
        future: _sessionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Không tìm thấy dữ liệu buổi học.'));
          }

          _session = snapshot.data!;
          // ✅ SỬA LỖI: Chỉ set text nếu controller rỗng (tránh ghi đè khi đang gõ)
          // Và thêm '??' để xử lý null
          if (_contentController.text.isEmpty) {
            _contentController.text = _session!.content ?? '';
          }

          return _buildContentBody(_session!);
        },
      ),
    );
  }

  Widget _buildContentBody(Session session) {
    // ✅ SỬA LỖI: Thêm '??' để xử lý null
    final String subject = session.label ?? '';
    // ✅ SỬA LỖI (Dự phòng): Thêm '??' để xử lý null
    final String room = session.classroom ?? '';
    final String formattedDate = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(session.date);
    final String timeRange = session.timeRange;

    // ✅✅✅ SỬA 2: SỬ DỤNG LẠI HÀM `getStatusInfo` ✅✅✅
    // 1. GỌI HÀM getStatusInfo() TỪ MODEL
    final statusInfo = session.getStatusInfo();
    final String statusText = statusInfo['text'];
    final Color statusColor = statusInfo['color'];

    return Center(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    // ✅ SỬA: Trả về 'false' khi nhấn nút back
                    onTap: () => Navigator.pop(context, false),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.grey.shade600),
                    ),
                  ),
                  const Text("Nội dung buổi học", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 12),
              Text(subject, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _primaryColor)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.location_on, 'Phòng học:', room),
                    _buildInfoRow(Icons.calendar_today, 'Ngày học:', formattedDate),
                    _buildInfoRow(Icons.access_time, 'Ca học:', timeRange),

                    // ✅✅✅ DÒNG ĐÃ THÊM ✅✅✅
                    _buildInfoRow(Icons.class_outlined, 'Lớp:', session.className ?? 'N/A'),

                    // ✅✅✅ SỬA 3: TRUYỀN `statusText` VÀ `valueColor` ✅✅✅
                    _buildInfoRow(Icons.schedule, 'Trạng thái:', statusText, valueColor: statusColor),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text("▌ Nội dung buổi học", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _showFilePickerDialog,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEFF1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_upload_outlined, color: Color(0xFF607D8B)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _pickedFile != null ? 'Đã đính kèm: ${_pickedFile!.name}' : "Thêm 1 file đính kèm...",
                          style: TextStyle(
                            color: _pickedFile != null ? Colors.black87 : const Color(0xFF607D8B),
                            fontStyle: _pickedFile != null ? FontStyle.normal : FontStyle.italic,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (_pickedFile != null)
                        GestureDetector(
                          onTap: () {
                            setState(() { _pickedFile = null; });
                          },
                          child: const Icon(Icons.close, size: 18, color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(hintText: "Nhập nội dung buổi học...", border: InputBorder.none, contentPadding: EdgeInsets.zero),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  // ================== (Logic nút Lưu giữ nguyên) ==================
                  onPressed: () async {
                    final String newContent = _contentController.text.trim();

                    if (newContent.isEmpty) {
                      await _showStatusDialog("Vui lòng nhập nội dung buổi học!", isSuccess: false);
                      return;
                    }

                    try {
                      // Gọi hàm updateSessionContent
                      // Hàm này sẽ gọi hàm PATCH trong api_service.dart
                      final updatedSession = await _repository.updateSessionContent(
                        widget.sessionId,
                        newContent,
                      );

                      // Cập nhật lại session trong state nếu cần
                      setState(() {
                        _session = updatedSession;
                      });

                      if (mounted) {
                        // ✅ SỬA: Đặt shouldPop = true để khi lưu thành công,
                        // nó sẽ tự động quay lại màn hình trước.
                        await _showStatusDialog("Lưu nội dung thành công!", isSuccess: true, shouldPop: true);
                      }

                    } catch (e) {
                      if (mounted) {
                        await _showStatusDialog("Lưu thất bại: ${e.toString()}", isSuccess: false);
                      }
                    }
                  },
                  // ================== (Kết thúc logic nút Lưu) ==================
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _greenSaveButton,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text("Lưu", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  // ✅ SỬA: Trả về 'false' khi nhấn nút "Quay lại"
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black12, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text("Quay lại", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}