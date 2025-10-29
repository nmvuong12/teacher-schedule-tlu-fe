import 'package:flutter/material.dart';
import '../../data/model/models.dart';

class SubjectForm extends StatefulWidget {
  final Subject? subject;
  final Function(Subject) onSubmit;

  const SubjectForm({
    super.key,
    this.subject,
    required this.onSubmit,
  });

  @override
  State<SubjectForm> createState() => _SubjectFormState();
}

class _SubjectFormState extends State<SubjectForm> {
  final _formKey = GlobalKey<FormState>();
  final _subjectNameController = TextEditingController();
  final _creditsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.subject != null) {
      _subjectNameController.text = widget.subject!.subjectName;
      _creditsController.text = widget.subject!.credits.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.subject == null ? 'Thêm môn học mới' : 'Chỉnh sửa môn học',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 24),
              
              // Subject name
              TextFormField(
                controller: _subjectNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên môn học',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên môn học';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Credits
              TextFormField(
                controller: _creditsController,
                decoration: const InputDecoration(
                  labelText: 'Số tín chỉ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tín chỉ';
                  }
                  final credits = int.tryParse(value);
                  if (credits == null || credits <= 0) {
                    return 'Số tín chỉ phải là số dương';
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
                        final subject = Subject(
                          subjectId: widget.subject?.subjectId,
                          subjectName: _subjectNameController.text,
                          credits: int.parse(_creditsController.text),
                        );
                        widget.onSubmit(subject);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(widget.subject == null ? 'Thêm' : 'Cập nhật'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _creditsController.dispose();
    super.dispose();
  }
}
