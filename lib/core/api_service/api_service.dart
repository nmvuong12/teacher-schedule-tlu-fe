import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Auth API
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: headers,
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // User Management
  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<Map<String, dynamic>> getUser(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$id'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user');
    }
  }

  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: headers,
      body: jsonEncode(user),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create user');
    }
  }

  static Future<void> updateUser(int id, Map<String, dynamic> user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: headers,
      body: jsonEncode(user),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  static Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: headers,
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  // Course Section Management (Học phần)
  static Future<List<dynamic>> getCourseSections() async {
    final response = await http.get(
      Uri.parse('$baseUrl/course-sections'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load course sections');
    }
  }

  static Future<Map<String, dynamic>> getCourseSection(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/course-sections/$id'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load course section');
    }
  }

  static Future<Map<String, dynamic>> createCourseSection(Map<String, dynamic> courseSection) async {
    final response = await http.post(
      Uri.parse('$baseUrl/course-sections'),
      headers: headers,
      body: jsonEncode(courseSection),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create course section: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> updateCourseSection(int id, Map<String, dynamic> courseSection) async {
    final response = await http.put(
      Uri.parse('$baseUrl/course-sections/$id'),
      headers: headers,
      body: jsonEncode(courseSection),
    );
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update course section: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> deleteCourseSection(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/course-sections/$id'),
      headers: headers,
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete course section');
    }
  }

  // Teaching Leave Management (Đơn xin nghỉ)
  static Future<List<dynamic>> getTeachingLeaves() async {
    final response = await http.get(
      Uri.parse('$baseUrl/teaching-leaves'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load teaching leaves');
    }
  }

  static Future<Map<String, dynamic>> getTeachingLeave(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/teaching-leaves/$id'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load teaching leave');
    }
  }

  static Future<Map<String, dynamic>> createTeachingLeave(Map<String, dynamic> teachingLeave) async {
    final response = await http.post(
      Uri.parse('$baseUrl/teaching-leaves'),
      headers: headers,
      body: jsonEncode(teachingLeave),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create teaching leave');
    }
  }

  static Future<void> updateTeachingLeave(int id, Map<String, dynamic> teachingLeave) async {
    final response = await http.put(
      Uri.parse('$baseUrl/teaching-leaves/$id'),
      headers: headers,
      body: jsonEncode(teachingLeave),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to update teaching leave');
    }
  }

  static Future<void> deleteTeachingLeave(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/teaching-leaves/$id'),
      headers: headers,
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete teaching leave');
    }
  }

  // Session Management (Buổi học)
  static Future<List<dynamic>> getSessions() async {
    // Use the scheduled endpoint that doesn't require teacherId
    final response = await http.get(
      Uri.parse('$baseUrl/sessions/scheduled'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load sessions');
    }
  }

  static Future<Map<String, dynamic>> createSession(Map<String, dynamic> session) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sessions'),
      headers: headers,
      body: jsonEncode(session),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create session: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> updateSession(int id, Map<String, dynamic> session) async {
    final response = await http.put(
      Uri.parse('$baseUrl/sessions/$id'),
      headers: headers,
      body: jsonEncode(session),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update session: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> deleteSession(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/sessions/$id'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete session: ${response.statusCode} ${response.body}');
    }
  }

  static Future<List<dynamic>> searchSessions(String keyword) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sessions/search?keyword=$keyword'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search sessions');
    }
  }

  static Future<List<dynamic>> getTodaySessions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/sessions'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final sessions = jsonDecode(response.body) as List;
      final today = DateTime.now();
      return sessions.where((session) {
        final sessionDate = DateTime.parse(session['date']);
        return sessionDate.year == today.year &&
               sessionDate.month == today.month &&
               sessionDate.day == today.day;
      }).toList();
    } else {
      throw Exception('Failed to load today sessions');
    }
  }

  // Teacher Management
  static Future<List<dynamic>> getTeachers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/teachers'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load teachers');
    }
  }

  static Future<Map<String, dynamic>> createTeacher(Map<String, dynamic> teacher) async {
    final response = await http.post(
      Uri.parse('$baseUrl/teachers'),
      headers: headers,
      body: jsonEncode(teacher),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create teacher: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> updateTeacher(int id, Map<String, dynamic> teacher) async {
    final response = await http.put(
      Uri.parse('$baseUrl/teachers/$id'),
      headers: headers,
      body: jsonEncode(teacher),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update teacher: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> deleteTeacher(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/teachers/$id'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete teacher: ${response.statusCode} ${response.body}');
    }
  }

  static Future<List<dynamic>> searchTeachers(String keyword) async {
    final response = await http.get(
      Uri.parse('$baseUrl/teachers/search?keyword=$keyword'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search teachers');
    }
  }

  // Subject Management
  static Future<List<dynamic>> getSubjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subjects'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  static Future<Map<String, dynamic>> createSubject(Map<String, dynamic> subject) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subjects'),
      headers: headers,
      body: jsonEncode(subject),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create subject: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> updateSubject(int id, Map<String, dynamic> subject) async {
    final response = await http.put(
      Uri.parse('$baseUrl/subjects/$id'),
      headers: headers,
      body: jsonEncode(subject),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update subject: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> deleteSubject(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/subjects/$id'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete subject: ${response.statusCode} ${response.body}');
    }
  }

  static Future<List<dynamic>> searchSubjects(String keyword) async {
    final response = await http.get(
      Uri.parse('$baseUrl/subjects/search?keyword=$keyword'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search subjects');
    }
  }

  // Class Management
  static Future<List<dynamic>> getClasses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/classes'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load classes');
    }
  }

  static Future<Map<String, dynamic>> createClass(Map<String, dynamic> clazz) async {
    final response = await http.post(
      Uri.parse('$baseUrl/classes'),
      headers: headers,
      body: jsonEncode(clazz),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create class: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> updateClass(int id, Map<String, dynamic> clazz) async {
    final response = await http.put(
      Uri.parse('$baseUrl/classes/$id'),
      headers: headers,
      body: jsonEncode(clazz),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update class: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> deleteClass(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/classes/$id'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete class: ${response.statusCode} ${response.body}');
    }
  }

  static Future<List<dynamic>> searchClasses(String keyword) async {
    final response = await http.get(
      Uri.parse('$baseUrl/classes/search?keyword=$keyword'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search classes');
    }
  }

  // Student Management
  static Future<List<dynamic>> getStudents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/students'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load students');
    }
  }

  static Future<Map<String, dynamic>> createStudent(Map<String, dynamic> student) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students'),
      headers: headers,
      body: jsonEncode(student),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create student: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> updateStudent(int id, Map<String, dynamic> student) async {
    final response = await http.put(
      Uri.parse('$baseUrl/students/$id'),
      headers: headers,
      body: jsonEncode(student),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update student: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> deleteStudent(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/students/$id'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete student: ${response.statusCode} ${response.body}');
    }
  }

  static Future<List<dynamic>> searchStudents(String keyword) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/search?keyword=$keyword'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search students');
    }
  }

  // Search functions
  static Future<List<dynamic>> searchUsers(String keyword) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/search?keyword=$keyword'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search users');
    }
  }

  static Future<List<dynamic>> searchCourseSections(String keyword) async {
    final response = await http.get(
      Uri.parse('$baseUrl/course-sections/search?keyword=$keyword'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search course sections');
    }
  }

  static Future<List<dynamic>> searchTeachingLeaves(String keyword) async {
    final response = await http.get(
      Uri.parse('$baseUrl/teaching-leaves/search?keyword=$keyword'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search teaching leaves');
    }
  }
}
