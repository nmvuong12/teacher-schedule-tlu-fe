import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/model/models.dart';
import '../controller/app_controller.dart';

class StudentForm extends StatefulWidget {
  final Student? student;
  final Function(Student) onSubmit;

  const StudentForm({
    super.key,
    this.student,
    required this.onSubmit,
  });

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  
  int? _selectedClassId;
  String _selectedClassName = '';

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _studentNameController.text = widget.student!.studentName;
      _selectedClassId = widget.student!.classId;
      _selectedClassName = widget.student!.className;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        return Dialog(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.student == null ? 'Thêm sinh viên mới' : 'Chỉnh sửa sinh viên',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Student name
                  TextFormField(
                    controller: _studentNameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên sinh viên',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên sinh viên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Class selection
                  Autocomplete<SchoolClass>(
                    displayStringForOption: (clazz) => clazz.className,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return controller.classes;
                      }
                      final query = textEditingValue.text.toLowerCase();
                      return controller.classes.where((c) => 
                        c.className.toLowerCase().contains(query));
                    },
                    onSelected: (SchoolClass selection) {
                      _selectedClassId = selection.classId;
                      _selectedClassName = selection.className;
                    },
                    fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                      textController.text = _selectedClassName;
                      return TextFormField(
                        controller: textController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Chọn lớp',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_selectedClassId == null) {
                            return 'Vui lòng chọn lớp';
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
                            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 500),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: options
                                  .map((clazz) => ListTile(
                                        title: Text(clazz.className),
                                        onTap: () => onSelected(clazz),
                                        dense: true,
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      );
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
                            final student = Student(
                              studentId: widget.student?.studentId ?? 0,
                              studentName: _studentNameController.text,
                              classId: _selectedClassId!,
                              className: _selectedClassName,
                            );
                            widget.onSubmit(student);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(widget.student == null ? 'Thêm' : 'Cập nhật'),
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

  @override
  void dispose() {
    _studentNameController.dispose();
    super.dispose();
  }
}