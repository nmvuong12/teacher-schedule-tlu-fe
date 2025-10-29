import 'package:flutter/material.dart';
import '../../data/model/models.dart';

class ClassForm extends StatefulWidget {
  final SchoolClass? clazz;
  final Function(SchoolClass) onSubmit;

  const ClassForm({
    super.key,
    this.clazz,
    required this.onSubmit,
  });

  @override
  State<ClassForm> createState() => _ClassFormState();
}

class _ClassFormState extends State<ClassForm> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.clazz != null) {
      _classNameController.text = widget.clazz!.className;
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
                widget.clazz == null ? 'Thêm lớp học mới' : 'Chỉnh sửa lớp học',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 24),
              
              // Class name
              TextFormField(
                controller: _classNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên lớp',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên lớp';
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
                        final clazz = SchoolClass(
                          classId: widget.clazz?.classId,
                          className: _classNameController.text,
                        );
                        widget.onSubmit(clazz);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(widget.clazz == null ? 'Thêm' : 'Cập nhật'),
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
    _classNameController.dispose();
    super.dispose();
  }
}
