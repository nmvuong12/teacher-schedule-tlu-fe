import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_service/api_service.dart';
import '../../data/model/models.dart';

class AppController extends ChangeNotifier {
  // Authentication
  User? _currentUser;
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
  List<User> _users = [];

  // Search and filters
  String _searchKeyword = '';
  String _selectedStatus = 'Tất cả trạng thái';

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  List<CourseSection> get courseSections => _courseSections;
  List<TeachingLeave> get teachingLeaves => _teachingLeaves;
  List<Session> get sessions => _sessions;
  List<Teacher> get teachers => _teachers;
  List<Subject> get subjects => _subjects;
  List<SchoolClass> get classes => _classes;
  List<Student> get students => _students;
  List<User> get users => _users;
  String get searchKeyword => _searchKeyword;
  String get selectedStatus => _selectedStatus;

  // Dashboard statistics
  int get totalCourses => _courseSections.length;
  int get totalTeachers => _teachers.length;
  int get pendingLeaveRequests => _teachingLeaves.where((leave) => leave.status == 0).length;
  int get progressWarnings => _sessions.where((session) => session.status == 'Đang diễn ra').length;

  // Today's sessions
  List<Session> get todaySessions {
    final today = DateTime.now();
    return _sessions.where((session) {
      return session.date.year == today.year &&
             session.date.month == today.month &&
             session.date.day == today.day;
    }).toList();
  }

  // Recent leave requests
  List<TeachingLeave> get recentLeaveRequests {
    final sortedLeaves = List<TeachingLeave>.from(_teachingLeaves);
    sortedLeaves.sort((a, b) => b.expectedMakeupDate.compareTo(a.expectedMakeupDate));
    return sortedLeaves.take(5).toList();
  }

  // Filtered course sections
  List<CourseSection> get filteredCourseSections {
    if (_searchKeyword.isEmpty) return _courseSections;
    return _courseSections.where((section) {
      return section.subjectName.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
             section.className.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
             section.teacherName.toLowerCase().contains(_searchKeyword.toLowerCase());
    }).toList();
  }

  // Filtered teaching leaves
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
      // Set demo user
      _currentUser = User(
        userId: 1,
        userName: 'admin',
        password: '',
        fullName: 'Administrator',
        email: 'admin@example.com',
        role: 1,
      );
      
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
      final data = await ApiService.getCourseSections();
      _courseSections = data.map((json) => CourseSection.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading course sections: $e');
    }
  }

  Future<void> loadTeachingLeaves() async {
    try {
      final data = await ApiService.getTeachingLeaves();
      _teachingLeaves = data.map((json) => TeachingLeave.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading teaching leaves: $e');
    }
  }

  Future<void> loadSessions() async {
    try {
      final data = await ApiService.getSessions();
      _sessions = data.map((json) => Session.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading sessions: $e');
    }
  }

  // CRUD for Sessions
  Future<bool> createSession(Session session) async {
    try {
      await ApiService.createSession(session.toJson());
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
        await ApiService.updateSession(session.sessionId!, session.toJson());
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
      await ApiService.deleteSession(sessionId);
      await loadSessions();
      return true;
    } catch (e) {
      print('Error deleting session: $e');
      return false;
    }
  }

  Future<void> loadTeachers() async {
    try {
      final data = await ApiService.getTeachers();
      _teachers = data.map((json) => Teacher.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading teachers: $e');
    }
  }

  // Teacher CRUD
  Future<bool> createTeacher(Teacher teacher) async {
    try {
      await ApiService.createTeacher(teacher.toJson());
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
        await ApiService.updateTeacher(teacher.teacherId!, teacher.toJson());
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
      await ApiService.deleteTeacher(teacherId);
      await loadTeachers();
      return true;
    } catch (e) {
      print('Error deleting teacher: $e');
      return false;
    }
  }

  Future<void> loadSubjects() async {
    try {
      final data = await ApiService.getSubjects();
      _subjects = data.map((json) => Subject.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading subjects: $e');
    }
  }

  // Subject CRUD
  Future<bool> createSubject(Subject subject) async {
    try {
      await ApiService.createSubject(subject.toJson());
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
        await ApiService.updateSubject(subject.subjectId!, subject.toJson());
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
      await ApiService.deleteSubject(subjectId);
      await loadSubjects();
      return true;
    } catch (e) {
      print('Error deleting subject: $e');
      return false;
    }
  }

  Future<void> loadClasses() async {
    try {
      final data = await ApiService.getClasses();
      _classes = data.map((json) => SchoolClass.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  // Class CRUD
  Future<bool> createClass(SchoolClass clazz) async {
    try {
      await ApiService.createClass(clazz.toJson());
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
        await ApiService.updateClass(clazz.classId!, clazz.toJson());
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
      await ApiService.deleteClass(classId);
      await loadClasses();
      return true;
    } catch (e) {
      print('Error deleting class: $e');
      return false;
    }
  }

  Future<void> loadStudents() async {
    try {
      final data = await ApiService.getStudents();
      _students = data.map((json) => Student.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  Future<void> loadUsers() async {
    try {
      final data = await ApiService.getUsers();
      _users = data.map((json) => User.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  // Student CRUD
  Future<bool> createStudent(Student student) async {
    try {
      await ApiService.createStudent(student.toJson());
      await loadStudents();
      return true;
    } catch (e) {
      print('Error creating student: $e');
      return false;
    }
  }

  Future<bool> updateStudent(Student student) async {
    try {
      await ApiService.updateStudent(student.studentId, student.toJson());
      await loadStudents();
      return true;
    } catch (e) {
      print('Error updating student: $e');
      return false;
    }
  }

  Future<bool> deleteStudent(int studentId) async {
    try {
      await ApiService.deleteStudent(studentId);
      await loadStudents();
      return true;
    } catch (e) {
      print('Error deleting student: $e');
      return false;
    }
  }

  // User CRUD
  Future<bool> createUser(User user) async {
    try {
      await ApiService.createUser(user.toJson());
      await loadUsers();
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      if (user.userId != null) {
        await ApiService.updateUser(user.userId!, user.toJson());
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
      await ApiService.deleteUser(userId);
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
      // Check for duplicates before creating
      if (isDuplicateCourseSection(courseSection)) {
        throw Exception('Học phần này đã tồn tại với cùng lớp, môn học, giảng viên, học kỳ và ca học');
      }
      
      await ApiService.createCourseSection(courseSection.toJson());
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
        await ApiService.updateCourseSection(courseSection.sectionId!, courseSection.toJson());
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
      await ApiService.deleteCourseSection(sectionId);
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
      await ApiService.updateTeachingLeave(teachingLeave.sessionId, teachingLeave.toJson());
      await loadTeachingLeaves();
      return true;
    } catch (e) {
      print('Error updating teaching leave: $e');
      return false;
    }
  }

  Future<bool> deleteTeachingLeave(int sessionId) async {
    try {
      await ApiService.deleteTeachingLeave(sessionId);
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
