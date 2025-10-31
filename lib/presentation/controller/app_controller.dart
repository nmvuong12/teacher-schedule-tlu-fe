// [app_controller.dart] - ĐÂY LÀ FILE ĐÃ SỬA
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_service/api_service.dart';
// [SỬA 1] - Ẩn User và Session (cũ)
import '../../data/model/models.dart' hide User, Session;
import '../../data/model/user_model.dart';
import '../../data/model/session_model.dart'; // Import Session (mới)

class AppController extends ChangeNotifier {
  // Authentication
  UserModel? _currentUser;
  bool _isLoggedIn = true; // Always logged in for demo
  bool _isLoading = false;

  // Data
  List<CourseSection> _courseSections = [];
  List<TeachingLeave> _teachingLeaves = [];
  List<Session> _sessions = [];
  List<Teacher> _teachers = [];
  List<Subject> _subjects = [];
  List<SchoolClass> _classes = [];
  List<Student> _students = [];
  List<UserModel> _users = []; // [SỬA 2] - Đổi sang UserModel

  // Search and filters
  String _searchKeyword = '';
  String _selectedStatus = 'Tất cả trạng thái';

  // Getters
  UserModel? get currentUser => _currentUser;

  set currentUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  List<CourseSection> get courseSections => _courseSections;
  List<TeachingLeave> get teachingLeaves => _teachingLeaves;
  List<Session> get sessions => _sessions;
  List<Teacher> get teachers => _teachers;
  List<Subject> get subjects => _subjects;
  List<SchoolClass> get classes => _classes;
  List<Student> get students => _students;
  List<UserModel> get users => _users; // [SỬA 3] - Đổi sang UserModel
  String get searchKeyword => _searchKeyword;
  String get selectedStatus => _selectedStatus;

  // (Các hàm getters thống kê, todaySessions, recentLeaveRequests... giữ nguyên)
  // ...
  int get totalCourses => _courseSections.length;
  int get totalTeachers => _teachers.length;
  int get pendingLeaveRequests => _teachingLeaves.where((leave) => leave.status == 0).length;
  int get progressWarnings => _sessions.where((session) => session.status == 'Đang diễn ra').length;
  List<Session> get todaySessions {
    final today = DateTime.now();
    return _sessions.where((session) {
      return session.date.year == today.year &&
          session.date.month == today.month &&
          session.date.day == today.day;
    }).toList();
  }
  List<TeachingLeave> get recentLeaveRequests {
    final sortedLeaves = List<TeachingLeave>.from(_teachingLeaves);
    sortedLeaves.sort((a, b) => b.expectedMakeupDate.compareTo(a.expectedMakeupDate));
    return sortedLeaves.take(5).toList();
  }
  List<CourseSection> get filteredCourseSections {
    if (_searchKeyword.isEmpty) return _courseSections;
    return _courseSections.where((section) {
      return section.subjectName.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
          section.className.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
          section.teacherName.toLowerCase().contains(_searchKeyword.toLowerCase());
    }).toList();
  }
  List<TeachingLeave> get filteredTeachingLeaves {
    List<TeachingLeave> filtered = _teachingLeaves;
    if (_searchKeyword.isNotEmpty) {
      filtered = filtered.where((leave) {
        return leave.reason.toLowerCase().contains(_searchKeyword.toLowerCase());
      }).toList();
    }
    if (_selectedStatus != 'Tất cả trạng thái') {
      filtered = filtered.where((leave) {
        return leave.statusName == _selectedStatus;
      }).toList();
    }
    return filtered;
  }

  // Initialize data on startup
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await loadInitialData();
    } catch (e) {
      print('Error initializing app: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Data loading methods
  Future<void> loadInitialData() async {
    if (!_isLoggedIn) return;

    _setLoading(true);
    try {
      await Future.wait([
        loadCourseSections(),
        loadTeachingLeaves(),
        loadSessions(),
        loadTeachers(),
        loadSubjects(),
        loadClasses(),
        loadStudents(),
        loadUsers(),
      ]);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCourseSections() async {
    try {
      final data = await ApiService.instance.getCourseSections();
      _courseSections = data.map((json) => CourseSection.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading course sections: $e');
    }
  }

  Future<void> loadTeachingLeaves() async {
    try {
      final data = await ApiService.instance.getTeachingLeaves();
      _teachingLeaves = data.map((json) => TeachingLeave.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading teaching leaves: $e');
    }
  }

  Future<void> loadSessions() async {
    try {
      final data = await ApiService.instance.getSessions();
      _sessions = data.map((json) => Session.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading sessions: $e');
    }
  }

  // CRUD for Sessions
  Future<bool> createSession(Session session) async {
    try {
      await ApiService.instance.createSession(session.toJson());
      await loadSessions();
      return true;
    } catch (e) {
      print('Error creating session: $e');
      return false;
    }
  }

  Future<bool> updateSession(Session session) async {
    try {
      if (session.sessionId != null) {
        await ApiService.instance.updateSession(session.sessionId!, session.toJson());
        await loadSessions();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating session: $e');
      return false;
    }
  }

  Future<bool> deleteSession(int sessionId) async {
    try {
      await ApiService.instance.deleteSession(sessionId);
      await loadSessions();
      return true;
    } catch (e) {
      print('Error deleting session: $e');
      return false;
    }
  }

  Future<void> loadTeachers() async {
    try {
      _teachers = await ApiService.instance.getTeachers();
      notifyListeners();
    } catch (e) {
      print('Error loading teachers: $e');
    }
  }

  // Teacher CRUD
  Future<bool> createTeacher(Teacher teacher) async {
    try {
      await ApiService.instance.createTeacher(teacher);
      await loadTeachers();
      return true;
    } catch (e) {
      print('Error creating teacher: $e');
      return false;
    }
  }

  Future<bool> updateTeacher(Teacher teacher) async {
    try {
      if (teacher.teacherId != null) {
        await ApiService.instance.updateTeacher(teacher.teacherId!, teacher.toJson());
        await loadTeachers();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating teacher: $e');
      return false;
    }
  }

  Future<bool> deleteTeacher(int teacherId) async {
    try {
      await ApiService.instance.deleteTeacher(teacherId);
      await loadTeachers();
      return true;
    } catch (e) {
      print('Error deleting teacher: $e');
      return false;
    }
  }

  Future<void> loadSubjects() async {
    try {
      final data = await ApiService.instance.getSubjects();
      _subjects = data.map((json) => Subject.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading subjects: $e');
    }
  }

  // Subject CRUD
  Future<bool> createSubject(Subject subject) async {
    try {
      await ApiService.instance.createSubject(subject.toJson());
      await loadSubjects();
      return true;
    } catch (e) {
      print('Error creating subject: $e');
      return false;
    }
  }

  Future<bool> updateSubject(Subject subject) async {
    try {
      if (subject.subjectId != null) {
        await ApiService.instance.updateSubject(subject.subjectId!, subject.toJson());
        await loadSubjects();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating subject: $e');
      return false;
    }
  }

  Future<bool> deleteSubject(int subjectId) async {
    try {
      await ApiService.instance.deleteSubject(subjectId);
      await loadSubjects();
      return true;
    } catch (e) {
      print('Error deleting subject: $e');
      return false;
    }
  }

  Future<void> loadClasses() async {
    try {
      final data = await ApiService.instance.getClasses();
      _classes = data.map((json) => SchoolClass.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  // Class CRUD
  Future<bool> createClass(SchoolClass clazz) async {
    try {
      await ApiService.instance.createClass(clazz.toJson());
      await loadClasses();
      return true;
    } catch (e) {
      print('Error creating class: $e');
      return false;
    }
  }

  Future<bool> updateClass(SchoolClass clazz) async {
    try {
      if (clazz.classId != null) {
        await ApiService.instance.updateClass(clazz.classId!, clazz.toJson());
        await loadClasses();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating class: $e');
      return false;
    }
  }

  Future<bool> deleteClass(int classId) async {
    try {
      await ApiService.instance.deleteClass(classId);
      await loadClasses();
      return true;
    } catch (e) {
      print('Error deleting class: $e');
      return false;
    }
  }

  Future<void> loadStudents() async {
    try {
      final data = await ApiService.instance.getStudents();
      _students = data.map((json) => Student.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  Future<void> loadUsers() async {
    try {
      _users = await ApiService.instance.getUsers();
      notifyListeners();
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  // Student CRUD
  Future<bool> createStudent(Student student) async {
    try {
      await ApiService.instance.createStudent(student.toJson());
      await loadStudents();
      return true;
    } catch (e) {
      print('Error creating student: $e');
      return false;
    }
  }

  Future<bool> updateStudent(Student student) async {
    try {
      await ApiService.instance.updateStudent(student.studentId, student.toJson());
      await loadStudents();
      return true;
    } catch (e) {
      print('Error updating student: $e');
      return false;
    }
  }

  Future<bool> deleteStudent(int studentId) async {
    try {
      await ApiService.instance.deleteStudent(studentId);
      await loadStudents();
      return true;
    } catch (e) {
      print('Error deleting student: $e');
      return false;
    }
  }

  // User CRUD
  // [SỬA 4] - Đổi tham số từ User -> UserModel
  Future<bool> createUser(UserModel user) async {
    try {
      await ApiService.instance.createUser(user.toJson());
      await loadUsers();
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  // [SỬA 5] - Đổi tham số từ User -> UserModel
  Future<bool> updateUser(UserModel user) async {
    try {
      if (user.id != null) {
        await ApiService.instance.updateUser(user.id, user.toJson());
        await loadUsers();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      await ApiService.instance.deleteUser(userId);
      await loadUsers();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Search and filter methods
  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  // Check for duplicate course section
  bool isDuplicateCourseSection(CourseSection courseSection) {
    return courseSections.any((existing) {
      return existing.sectionId != courseSection.sectionId && // Different section
          existing.classId == courseSection.classId &&
          existing.subjectId == courseSection.subjectId &&
          existing.teacherId == courseSection.teacherId &&
          existing.semester == courseSection.semester &&
          existing.shift == courseSection.shift;
    });
  }

  // CRUD operations for Course Sections
  Future<bool> createCourseSection(CourseSection courseSection) async {
    try {
      if (isDuplicateCourseSection(courseSection)) {
        throw Exception('Học phần này đã tồn tại với cùng lớp, môn học, giảng viên, học kỳ và ca học');
      }

      await ApiService.instance.createCourseSection(courseSection.toJson());
      await loadCourseSections();
      return true;
    } catch (e) {
      print('Error creating course section: $e');
      return false;
    }
  }

  Future<bool> updateCourseSection(CourseSection courseSection) async {
    try {
      if (courseSection.sectionId != null) {
        await ApiService.instance.updateCourseSection(courseSection.sectionId!, courseSection.toJson());
        await loadCourseSections();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating course section: $e');
      return false;
    }
  }

  Future<bool> deleteCourseSection(int sectionId) async {
    try {
      await ApiService.instance.deleteCourseSection(sectionId);
      await loadCourseSections();
      return true;
    } catch (e) {
      print('Error deleting course section: $e');
      return false;
    }
  }

  // CRUD operations for Teaching Leaves
  Future<bool> updateTeachingLeave(TeachingLeave teachingLeave) async {
    try {
      await ApiService.instance.updateTeachingLeave(teachingLeave.sessionId, teachingLeave.toJson());
      await loadTeachingLeaves();
      return true;
    } catch (e) {
      print('Error updating teaching leave: $e');
      return false;
    }
  }

  Future<bool> deleteTeachingLeave(int sessionId) async {
    try {
      await ApiService.instance.deleteTeachingLeave(sessionId);
      await loadTeachingLeaves();
      return true;
    } catch (e) {
      print('Error deleting teaching leave: $e');
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    await loadInitialData();
  }
}