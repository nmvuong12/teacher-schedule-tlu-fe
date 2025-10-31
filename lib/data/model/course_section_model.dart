import 'dart:convert';
import 'package:collection/collection.dart';

// Model để biểu diễn một lớp học riêng lẻ
class CourseClass {
  final int sectionId;
  final String name;

  CourseClass({required this.sectionId, required this.name});
}

// Model chính, đại diện cho một môn học được nhóm lại
class GroupedCourse {
  final String subjectName;
  final int semester;
  final DateTime startDate;
  // ================== SỬA: THÊM TEACHER ID ==================
  final int teacherId;
  final List<CourseClass> classes;

  GroupedCourse({
    required this.subjectName,
    required this.semester,
    required this.startDate,
    required this.teacherId, // Thêm vào constructor
    required this.classes,
  });
}


// --- Dưới đây là model để parse dữ liệu gốc từ API ---

List<CourseSection> courseSectionFromJson(String str) => List<CourseSection>.from(json.decode(str).map((x) => CourseSection.fromJson(x)));

class CourseSection {
  final int sectionId;
  final int classId;
  final String className;
  final int subjectId;
  final String subjectName;
  final int semester;
  final String? shift;
  final DateTime startDate;
  final DateTime endDate;
  final int weeklySessions;
  final int teacherId;
  final String teacherName;

  CourseSection({
    required this.sectionId,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.semester,
    this.shift,
    required this.startDate,
    required this.endDate,
    required this.weeklySessions,
    required this.teacherId,
    required this.teacherName,
  });

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    dynamic _parseDynamic(dynamic value) {
      if (value is String) return int.tryParse(value) ?? value;
      return value;
    }

    return CourseSection(
      sectionId: _parseInt(json["sectionId"]),
      classId: _parseInt(json["classId"]),
      className: json["className"] ?? '',
      subjectId: _parseInt(json["subjectId"]),
      subjectName: json["subjectName"] ?? '',
      semester: _parseInt(json["semester"]),
      shift: json["shift"],
      startDate: DateTime.parse(json["startDate"]),
      endDate: DateTime.parse(json["endDate"]),
      weeklySessions: _parseInt(json["weeklySessions"]),
      teacherId: _parseInt(json["teacherId"]),
      teacherName: json["teacherName"] ?? 'N/A',
    );
  }
}

// --- Hàm Helper để nhóm dữ liệu ---
List<GroupedCourse> groupCourseSections(List<CourseSection> sections) {
  if (sections.isEmpty) {
    return [];
  }

  final groupedBySubject = groupBy(sections, (section) => section.subjectName);

  return groupedBySubject.entries.map((entry) {
    final subjectName = entry.key;
    final subjectSections = entry.value;

    final firstSection = subjectSections.first;
    final semester = firstSection.semester;
    final startDate = firstSection.startDate;
    // ================== SỬA: LẤY TEACHER ID ==================
    final teacherId = firstSection.teacherId;

    final classes = subjectSections.map((section) {
      return CourseClass(sectionId: section.sectionId, name: section.className);
    }).toList();

    return GroupedCourse(
      subjectName: subjectName,
      semester: semester,
      startDate: startDate,
      teacherId: teacherId, // Gán teacherId
      classes: classes,
    );
  }).toList();
}

