// [session_form.dart] - ĐÃ SỬA LỖI
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// [SỬA 1] - Sửa lỗi import
import '../../data/model/models.dart' hide Session;
import '../../data/model/session_model.dart';
import '../../data/model/course_section.dart'; // Giả sử đây là nơi chứa CourseSection
import '../controller/app_controller.dart';

class SessionForm extends StatefulWidget {
  final Session? session;
  final Function(Session) onSubmit;

  const SessionForm({
    super.key,
    this.session,
    required this.onSubmit,
  });

  @override
  State<SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends State<SessionForm> {
  final _formKey = GlobalKey<FormState>();
  final _classroomController = TextEditingController();
  final _contentController = TextEditingController();
  final _labelController = TextEditingController();

  int? _selectedSectionId;
  String _selectedSectionName = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 0);

  // [SỬA 2] - Đổi trạng thái mặc định cho đúng với model
  String _selectedStatus = 'Đã lên lịch'; // 'Chưa bắt đầu' không tồn tại trong model

  @override
  void initState() {
    super.initState();
    if (widget.session != null) {
      _classroomController.text = widget.session!.classroom;
      // [SỬA 3] - Thêm '??' để tránh lỗi gán null cho controller
      _contentController.text = widget.session!.content ?? '';
      _labelController.text = widget.session!.label ?? '';

      _selectedDate = widget.session!.date;
      _startTime = TimeOfDay.fromDateTime(widget.session!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.session!.endTime);
      _selectedStatus = widget.session!.status;
      _selectedSectionId = widget.session!.sectionId;

      // [SỬA 4] - Đổi 'sectionName' (cũ) -> 'className' (mới)
      _selectedSectionName = widget.session!.className ?? widget.session!.subjectName ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        return Dialog(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.session == null ? 'Thêm buổi học mới' : 'Chỉnh sửa buổi học',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section selection
                  widget.session == null
                      ? Autocomplete<CourseSection>(
                    displayStringForOption: (section) => '${section.subjectName} - ${section.className}',
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return controller.courseSections;
                      }
                      final query = textEditingValue.text.toLowerCase();
                      return controller.courseSections.where((s) =>
                      s.subjectName.toLowerCase().contains(query) ||
                          s.className.toLowerCase().contains(query));
                    },
                    onSelected: (CourseSection selection) {
                      _selectedSectionId = selection.sectionId;
                      _selectedSectionName = '${selection.subjectName} - ${selection.className}';
                    },
                    fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                      textController.text = _selectedSectionName;
                      return TextFormField(
                        controller: textController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Chọn học phần',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_selectedSectionId == null) {
                            return 'Vui lòng chọn học phần';
                          }
                          return null;
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 600),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: options
                                  .map((section) => ListTile(
                                title: Text(section.subjectName),
                                subtitle: Text(section.className),
                                onTap: () => onSelected(section),
                                dense: true,
                              ))
                                  .toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                      : TextFormField(
                    initialValue: _selectedSectionName,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Học phần',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFF3F4F6),
                      helperText: 'Không thể thay đổi học phần khi chỉnh sửa',
                      helperMaxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date and time
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                _selectedDate = date;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Ngày học',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(_formatDate(_selectedDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _startTime,
                            );
                            if (time != null) {
                              setState(() {
                                _startTime = time;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Giờ bắt đầu',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(_startTime.format(context)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _endTime,
                            );
                            if (time != null) {
                              setState(() {
                                _endTime = time;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Giờ kết thúc',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(_endTime.format(context)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Classroom and content
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _classroomController,
                          decoration: const InputDecoration(
                            labelText: 'Phòng học',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập phòng học';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Trạng thái',
                            border: OutlineInputBorder(),
                          ),
                          // [SỬA 5] - Cập nhật danh sách trạng thái
                          // để khớp với hàm getStatusInfo() trong model
                          items: const [
                            DropdownMenuItem(value: 'Đã lên lịch', child: Text('Đã lên lịch')),
                            DropdownMenuItem(value: 'Đã hoàn thành', child: Text('Đã hoàn thành')),
                            DropdownMenuItem(value: 'Đã hủy', child: Text('Đã hủy')),
                            DropdownMenuItem(value: 'Đã yêu cầu xin nghỉ', child: Text('Đã yêu cầu xin nghỉ')),
                            DropdownMenuItem(value: 'Từ chối xin nghỉ - Đã lên lịch', child: Text('Từ chối - Đã lên lịch')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Content and label
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Nội dung buổi học (Không bắt buộc)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    // [SỬA 6] - Xóa validator
                    // vì 'content' trong model là 'String?' (optional)
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _labelController,
                    decoration: const InputDecoration(
                      labelText: 'Nhãn buổi học (VD: Buổi 1)',
                      border: OutlineInputBorder(),
                    ),
                    // [SỬA 6] - Xóa validator
                    // vì 'label' trong model là 'String?' (optional)
                    // (Bạn có thể thêm lại nếu muốn nó là bắt buộc trên UI)
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập nhãn buổi học';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Hủy'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // [SỬA 7] - Lấy subjectName và className
                            String? subjectName;
                            String? className;

                            if (widget.session != null) {
                              // Đang edit, giữ nguyên
                              subjectName = widget.session!.subjectName;
                              className = widget.session!.className;
                            } else {
                              // Đang tạo mới, tìm từ controller
                              try {
                                final selectedSection = controller.courseSections.firstWhere(
                                      (s) => s.sectionId == _selectedSectionId,
                                );
                                subjectName = selectedSection.subjectName;
                                className = selectedSection.className;
                              } catch(e) {
                                // Không tìm thấy section, dùng tên đã lưu
                                final parts = _selectedSectionName.split(' - ');
                                subjectName = parts.isNotEmpty ? parts[0] : 'N/A';
                                className = parts.length > 1 ? parts[1] : 'N/A';
                              }
                            }

                            final session = Session(
                              sessionId: widget.session?.sessionId,
                              sectionId: _selectedSectionId!,
                              date: _selectedDate,
                              classroom: _classroomController.text,
                              status: _selectedStatus,
                              // Truyền null nếu rỗng, vì model là 'String?'
                              content: _contentController.text.isEmpty ? null : _contentController.text,
                              label: _labelController.text.isEmpty ? null : _labelController.text,
                              startTime: DateTime(1970, 1, 1, _startTime.hour, _startTime.minute),
                              endTime: DateTime(1970, 1, 1, _endTime.hour, _endTime.minute),
                              // Thêm các trường đã gộp
                              subjectName: subjectName,
                              className: className,
                            );
                            widget.onSubmit(session);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(widget.session == null ? 'Thêm' : 'Cập nhật'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void dispose() {
    _classroomController.dispose();
    _contentController.dispose();
    _labelController.dispose();
    super.dispose();
  }
}