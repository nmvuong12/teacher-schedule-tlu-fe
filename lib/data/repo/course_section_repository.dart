import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/course_section_model.dart';
import '../model/user_model.dart'; // Cần import UserModel

class CourseSectionRepository {
  // !!! THAY THẾ BẰNG ĐỊA CHỈ BACKEND CỦA BẠN !!!
  // Dùng http://10.0.2.2:8080 nếu chạy trên máy ảo Android
  final String _baseUrl = "http://10.0.2.2:8080/api";

  /// Lấy tất cả các học phần (không lọc)
  Future<List<GroupedCourse>> fetchAndGroupCourses() async {
    final response = await http.get(Uri.parse('$_baseUrl/course-sections'));

    if (response.statusCode == 200) {
      final List<CourseSection> sections = courseSectionFromJson(utf8.decode(response.bodyBytes));
      return groupCourseSections(sections);
    } else {
      throw Exception('Failed to load all course sections');
    }
  }

  /// Lấy các học phần theo ID của giáo viên
  Future<List<GroupedCourse>> fetchAndGroupCoursesByTeacher(int teacherId) async {
    final response = await http.get(Uri.parse('$_baseUrl/course-sections/teacher/$teacherId'));

    if (response.statusCode == 200) {
      final List<CourseSection> sections = courseSectionFromJson(utf8.decode(response.bodyBytes));
      return groupCourseSections(sections);
    } else {
      throw Exception('Failed to load course sections for teacher $teacherId');
    }
  }
}

