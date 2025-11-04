import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/teacher_dto.dart';
import '../../core/api_client.dart';

class TeacherRepository {
  // Lấy teacher theo id (có thể là teacherId hoặc userId)
  // Backend có thể đang expect userId thay vì teacherId
  Future<TeacherDto> getById(int id) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/api/teachers/$id');
    print('📞 TeacherRepository.getById: Calling API: $uri');
    print('📞 Requested id: $id (could be teacherId or userId)');
    
    final res = await http.get(uri, headers: ApiClient.jsonHeaders);
    print('📥 Response status: ${res.statusCode}');
    print('📥 Response body: ${res.body}');
    
    if (res.statusCode != 200) {
      throw Exception('GET /api/teachers/$id failed: ${res.statusCode} ${res.body}');
    }
    
    final responseData = json.decode(res.body) as Map<String, dynamic>;
    print('📦 Response data keys: ${responseData.keys.toList()}');
    print('📦 Response teacherId: ${responseData['teacherId']}');
    print('📦 Response userId: ${responseData['userId']}');
    print('📦 Response userName: ${responseData['userName']}');
    print('📦 Response fullName: ${responseData['fullName']}');
    
    final dto = TeacherDto.fromJson(responseData);
    print('✅ TeacherDto parsed - teacherId: ${dto.teacherId}, userId: ${dto.userId}, userName: ${dto.userName}, fullName: ${dto.fullName}');
    
    // Verify: nếu id không khớp với teacherId, có thể backend đang dùng userId
    if (dto.teacherId != id && dto.userId != id) {
      print('⚠️ WARNING: Requested id=$id but got teacherId=${dto.teacherId}, userId=${dto.userId}');
      print('⚠️ Backend might be using userId instead of teacherId for this endpoint');
    } else if (dto.userId == id) {
      print('✅ Confirmed: Backend is using userId for this endpoint');
    } else if (dto.teacherId == id) {
      print('✅ Confirmed: Backend is using teacherId for this endpoint');
    }
    
    return dto;
  }

  // Lấy teacher theo userId
  Future<TeacherDto> getByUserId(int userId) async {
    // Thử 1: API /api/teachers/{id} có thể đang expect userId
    try {
      print('📞 TeacherRepository.getByUserId: Trying /api/teachers/$userId (might expect userId)');
      final dto = await getById(userId);
      // Verify userId matches
      if (dto.userId == userId) {
        print('✅ getByUserId successful via getById - userId matches!');
        return dto;
      } else {
        print('⚠️ getById returned different userId (expected: $userId, got: ${dto.userId})');
      }
    } catch (e) {
      print('⚠️ getById with userId failed: $e');
    }
    
    // Thử 2: Endpoint /api/teachers/user/{userId}
    try {
      final uri = Uri.parse('${ApiClient.baseUrl}/api/teachers/user/$userId');
      print('📞 TeacherRepository.getByUserId: Trying endpoint: $uri');
      
      final res = await http.get(uri, headers: ApiClient.jsonHeaders);
      print('📥 Response status: ${res.statusCode}');
      print('📥 Response body: ${res.body}');
      
      if (res.statusCode == 200) {
        final responseData = json.decode(res.body) as Map<String, dynamic>;
        final dto = TeacherDto.fromJson(responseData);
        if (dto.userId == userId) {
          print('✅ getByUserId successful via /api/teachers/user/{userId}');
          return dto;
        }
      }
    } catch (e) {
      print('⚠️ /api/teachers/user/{userId} endpoint not available: $e');
    }
    
    // Fallback: Lấy tất cả teachers và filter theo userId
    print('🔄 Fallback: Getting all teachers and filtering by userId=$userId');
    try {
      final allTeachers = await getAll();
      final teacher = allTeachers.firstWhere(
        (t) => t.userId == userId,
        orElse: () => throw Exception('Teacher not found for userId: $userId'),
      );
      print('✅ getByUserId successful via getAll + filter');
      return teacher;
    } catch (e) {
      print('❌ getByUserId failed: $e');
      rethrow;
    }
  }

  Future<List<TeacherDto>> getAll() async {
    final uri = Uri.parse('${ApiClient.baseUrl}/api/teachers');
    final res = await http.get(uri, headers: ApiClient.jsonHeaders);
    if (res.statusCode != 200) {
      throw Exception('GET /api/teachers failed: ${res.statusCode} ${res.body}');
    }
    final List data = json.decode(res.body) as List;
    return data.map((e) => TeacherDto.fromJson(e as Map<String, dynamic>)).toList();
  }
}


















