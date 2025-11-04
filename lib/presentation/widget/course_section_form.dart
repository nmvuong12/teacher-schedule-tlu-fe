import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/model/models.dart';
import '../controller/app_controller.dart';

class CourseSectionForm extends StatefulWidget {
  final CourseSection? courseSection;
  final Function(CourseSection) onSubmit;

  const CourseSectionForm({
    super.key,
    this.courseSection,
    required this.onSubmit,
  });

  @override
  State<CourseSectionForm> createState() => _CourseSectionFormState();
}

class _CourseSectionFormState extends State<CourseSectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _subjectNameController = TextEditingController();
  final _classNameController = TextEditingController();
  final _teacherNameController = TextEditingController();
  // Weekly sessions now selected via chips, controller removed
  
  String _selectedSemester = '';
  String _selectedShift = '1';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 90));
  String _selectedClassroom = '111';

  List<String> get _classroomOptions =>
      List<String>.generate(41, (index) => (111 + index).toString());

  // Selected entities
  Subject? _selectedSubject;
  SchoolClass? _selectedClass;
  Teacher? _selectedTeacher;
  final Set<String> _selectedWeekdays = <String>{};
  bool _preselectedFromExisting = false;

  List<String> get _semesterOptions {
    final now = DateTime.now();
    final startYear = now.month >= 8 ? now.year : now.year - 1;
    final endYear = startYear + 1;
    return [
      'HK1-$startYear-$endYear',
      'HK2-$startYear-$endYear',
    ];
  }

  final List<Map<String, dynamic>> _shiftOptions = const [
    {'value': '1', 'label': 'Ca 1 (07:00 - 09:35)'},
    {'value': '2', 'label': 'Ca 2 (09:40 - 12:25)'},
    {'value': '3', 'label': 'Ca 3 (12:55 - 15:35)'},
    {'value': '4', 'label': 'Ca 4 (15:40 - 18:20)'},
  ];

  static const List<String> _weekdayLabels = <String>[
    'Hai', 'Ba', 'Tư', 'Năm', 'Sáu', 'Bảy', 'Chủ nhật'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.courseSection != null) {
      _subjectNameController.text = widget.courseSection!.subjectName;
      _classNameController.text = widget.courseSection!.className;
      _teacherNameController.text = widget.courseSection!.teacherName;
      // Preselect weekdays from stored codes -> labels
      final rawWeekdays = widget.courseSection!.weeklySessions.split(',');
      for (final w in rawWeekdays) {
        final trimmed = w.trim();
        if (trimmed.isEmpty) continue;
        switch (trimmed) {
          case '2': _selectedWeekdays.add('Hai'); break;
          case '3': _selectedWeekdays.add('Ba'); break;
          case '4': _selectedWeekdays.add('Tư'); break;
          case '5': _selectedWeekdays.add('Năm'); break;
          case '6': _selectedWeekdays.add('Sáu'); break;
          case '7': _selectedWeekdays.add('Bảy'); break;
          case '8': _selectedWeekdays.add('Chủ nhật'); break;
          default: _selectedWeekdays.add(trimmed); // fallback
        }
      }
      _selectedSemester = widget.courseSection!.semester;
      // Normalize shift to numeric 1-4 for dropdown value
      final s = (widget.courseSection!.shift).toString().trim().toLowerCase();
      if (RegExp(r'^[1-4]$').hasMatch(s)) {
        _selectedShift = s;
      } else if (s == 'sáng' || s == 'morning' || s == 'ca 1') {
        _selectedShift = '1';
      } else if (s == 'chiều' || s == 'afternoon' || s == 'ca 2') {
        _selectedShift = '2';
      } else if (s == 'tối' || s == 'evening' || s == 'ca 3') {
        _selectedShift = '3';
      } else if (s == 'ca 4') {
        _selectedShift = '4';
      } else {
        _selectedShift = '1';
      }
      _startDate = widget.courseSection!.startDate;
      _endDate = widget.courseSection!.endDate;
      if ((widget.courseSection!.classroom ?? '').isNotEmpty) {
        _selectedClassroom = widget.courseSection!.classroom!;
      }
    }
    // Fallback semester default
    if (_selectedSemester.isEmpty) {
      _selectedSemester = _semesterOptions.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, child) {
        // Preselect dropdown/autocomplete values from existing section once controller data is loaded
        if (widget.courseSection != null && !_preselectedFromExisting) {
          final existing = widget.courseSection!;
          if (controller.subjects.isNotEmpty) {
            _selectedSubject = controller.subjects.firstWhere(
              (s) => s.subjectId == existing.subjectId,
              orElse: () => _selectedSubject ?? (controller.subjects.isNotEmpty ? controller.subjects.first : null)!,
            );
            _subjectNameController.text = existing.subjectName;
          }
          if (controller.classes.isNotEmpty) {
            _selectedClass = controller.classes.firstWhere(
              (c) => c.classId == existing.classId,
              orElse: () => _selectedClass ?? (controller.classes.isNotEmpty ? controller.classes.first : null)!,
            );
            _classNameController.text = existing.className;
          }
          if (controller.teachers.isNotEmpty) {
            _selectedTeacher = controller.teachers.firstWhere(
              (t) => t.teacherId == existing.teacherId,
              orElse: () => _selectedTeacher ?? (controller.teachers.isNotEmpty ? controller.teachers.first : null)!,
            );
            _teacherNameController.text = existing.teacherName;
          }
          _preselectedFromExisting = true;
        }
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
                    widget.courseSection == null ? 'Thêm học phần mới' : 'Chỉnh sửa học phần',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Subject (searchable)
                  _buildSubjectAutocomplete(context),
                  const SizedBox(height: 16),
                  
                  // Class (searchable)
                  _buildClassAutocomplete(context),
                  const SizedBox(height: 16),
                  
                  // Teacher (searchable)
                  _buildTeacherAutocomplete(context),
                  const SizedBox(height: 16),
                  
                  // Weekly sessions (select weekdays)
                  _buildWeekdaySelector(),
                  const SizedBox(height: 16),
                  
                  // Semester and Shift
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSemester,
                          decoration: const InputDecoration(
                            labelText: 'Học kỳ',
                            border: OutlineInputBorder(),
                          ),
                          items: _semesterOptions
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSemester = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedShift,
                          decoration: const InputDecoration(
                            labelText: 'Ca học',
                            border: OutlineInputBorder(),
                          ),
                          items: _shiftOptions
                              .map((e) => DropdownMenuItem(value: e['value'] as String, child: Text(e['label'] as String)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedShift = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Classroom selector
                  DropdownButtonFormField<String>(
                    value: _selectedClassroom,
                    decoration: const InputDecoration(
                      labelText: 'Phòng học',
                      border: OutlineInputBorder(),
                    ),
                    items: _classroomOptions
                        .map((c) => DropdownMenuItem(value: c, child: Text('Phòng $c')))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedClassroom = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Start and End dates
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                _startDate = date;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Ngày bắt đầu',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(_formatDate(_startDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate,
                              firstDate: _startDate,
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                _endDate = date;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Ngày kết thúc',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(_formatDate(_endDate)),
                          ),
                        ),
                      ),
                    ],
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
                            // Allow existing IDs/names to pass through without forcing reselection
                            final effectiveSubjectId = _selectedSubject?.subjectId ?? widget.courseSection?.subjectId;
                            final effectiveSubjectName = _selectedSubject?.subjectName ?? widget.courseSection?.subjectName ?? _subjectNameController.text;
                            final effectiveClassId = _selectedClass?.classId ?? widget.courseSection?.classId;
                            final effectiveClassName = _selectedClass?.className ?? widget.courseSection?.className ?? _classNameController.text;
                            final effectiveTeacherId = _selectedTeacher?.teacherId ?? widget.courseSection?.teacherId;
                            final effectiveTeacherName = _selectedTeacher?.userName ?? widget.courseSection?.teacherName ?? _teacherNameController.text;

                            if (effectiveSubjectId == null || effectiveClassId == null || effectiveTeacherId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vui lòng chọn học phần, lớp và giảng viên hợp lệ')),
                              );
                              return;
                            }
                            String _weekdayToCode(String label) {
                              switch (label) {
                                case 'Hai': return '2';
                                case 'Ba': return '3';
                                case 'Tư': return '4';
                                case 'Năm': return '5';
                                case 'Sáu': return '6';
                                case 'Bảy': return '7';
                                case 'Chủ nhật': return '8'; // dùng 8 đại diện CN
                                default: return label;
                              }
                            }
                            final weekly = _selectedWeekdays.map(_weekdayToCode).join(',');

                            final courseSection = CourseSection(
                              sectionId: widget.courseSection?.sectionId,
                              classId: effectiveClassId,
                              className: effectiveClassName,
                              subjectId: effectiveSubjectId,
                              subjectName: effectiveSubjectName,
                              semester: _selectedSemester,
                              shift: _selectedShift,
                              startDate: _startDate,
                              endDate: _endDate,
                              weeklySessions: weekly,
                              teacherId: effectiveTeacherId,
                              teacherName: effectiveTeacherName,
                              classroom: _selectedClassroom,
                            );
                            widget.onSubmit(courseSection);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(widget.courseSection == null ? 'Thêm' : 'Cập nhật'),
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

  String _codeToWeekdayLabel(String code) {
    switch (code) {
      case '2': return 'Hai';
      case '3': return 'Ba';
      case '4': return 'Tư';
      case '5': return 'Năm';
      case '6': return 'Sáu';
      case '7': return 'Bảy';
      case '8': return 'Chủ nhật';
      default: return code;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildSubjectAutocomplete(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        final options = controller.subjects;
        return Autocomplete<Subject>(
          displayStringForOption: (s) => s.subjectName,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return options;
            }
            final query = textEditingValue.text.toLowerCase();
            return options.where((s) => s.subjectName.toLowerCase().contains(query));
          },
          onSelected: (Subject selection) {
            _selectedSubject = selection;
            _subjectNameController.text = selection.subjectName;
          },
          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
            // Use our controller so we can preset editing text
            textController.text = _subjectNameController.text;
            return TextFormField(
              controller: textController,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'Tên môn học',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn học phần';
                }
                return null;
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return _buildOptionsPopup<Subject>(options, (s) => s.subjectName, onSelected);
          },
        );
      },
    );
  }

  Widget _buildClassAutocomplete(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        final options = controller.classes;
        return Autocomplete<SchoolClass>(
          displayStringForOption: (c) => c.className,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return options;
            }
            final query = textEditingValue.text.toLowerCase();
            return options.where((c) => c.className.toLowerCase().contains(query));
          },
          onSelected: (SchoolClass selection) {
            _selectedClass = selection;
            _classNameController.text = selection.className;
          },
          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
            textController.text = _classNameController.text;
            return TextFormField(
              controller: textController,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'Tên lớp',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn lớp';
                }
                return null;
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return _buildOptionsPopup<SchoolClass>(options, (c) => c.className, onSelected);
          },
        );
      },
    );
  }

  Widget _buildTeacherAutocomplete(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        final options = controller.teachers;
        return Autocomplete<Teacher>(
          displayStringForOption: (t) => t.userName,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return options;
            }
            final query = textEditingValue.text.toLowerCase();
            return options.where((t) => t.userName.toLowerCase().contains(query));
          },
          onSelected: (Teacher selection) {
            _selectedTeacher = selection;
            _teacherNameController.text = selection.userName;
          },
          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
            textController.text = _teacherNameController.text;
            return TextFormField(
              controller: textController,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'Tên giảng viên',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn giảng viên';
                }
                return null;
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return _buildOptionsPopup<Teacher>(options, (t) => t.userName, onSelected);
          },
        );
      },
    );
  }

  Widget _buildOptionsPopup<T extends Object>(
    Iterable<T> options,
    String Function(T) getLabel,
    AutocompleteOnSelected<T> onSelected,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240, maxWidth: 600),
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: options
                .map(
                  (opt) => ListTile(
                    title: Text(getLabel(opt)),
                    onTap: () => onSelected(opt),
                    dense: true,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekdaySelector() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Buổi trong tuần',
        border: OutlineInputBorder(),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _weekdayLabels.map((label) {
          final selected = _selectedWeekdays.contains(label);
          return FilterChip(
            label: Text(label),
            selected: selected,
            onSelected: (value) {
              setState(() {
                if (value) {
                  _selectedWeekdays.add(label);
                } else {
                  _selectedWeekdays.remove(label);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _classNameController.dispose();
    _teacherNameController.dispose();
    super.dispose();
  }
}
