import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_client.dart';
import '../model/student_dto.dart';
import '../model/section_dto.dart';

class StudentRepository {
  // Lấy thông tin sinh viên theo ID
  Future<StudentDto> getById(int studentId) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/api/students/$studentId');
    final res = await http.get(uri, headers: ApiClient.jsonHeaders);
    if (res.statusCode != 200) {
      throw Exception('GET student failed: ${res.statusCode} ${res.body}');
    }
    final data = json.decode(res.body);
    return StudentDto.fromJson(data);
  }

  // Lấy danh sách các học phần mà sinh viên đang học
  // Ưu tiên: lấy sections có attendance data
  // Fallback: lấy sections theo class của sinh viên (không cần attendance)
  Future<List<SectionDto>> getSectionsByStudent(int studentId) async {
    // Bước 1: Thử lấy sections có attendance data
    final uri = Uri.parse('${ApiClient.baseUrl}/api/course-sections/student/$studentId/enrolled');
    print('📞 Calling API: $uri');
    
    final res = await http.get(uri, headers: ApiClient.jsonHeaders).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('Timeout: API mất quá 30 giây!');
      },
    );
    print('📥 Response status: ${res.statusCode}');
    print('📥 Response body length: ${res.body.length} chars');
    print('📥 Response body: ${res.body}');
    
    if (res.statusCode != 200) {
      throw Exception('GET course sections by student failed: ${res.statusCode} ${res.body}');
    }
    
    // Parse response
    if (res.body.trim().isEmpty || res.body.trim() == 'null' || res.body.trim() == '[]') {
      print('⚠️ No sections with attendance data - trying fallback: get sections by class');
      return await _getSectionsByClass(studentId);
    }
    
    final decoded = json.decode(res.body);
    if (decoded == null || decoded is! List) {
      print('⚠️ Invalid response - trying fallback');
      return await _getSectionsByClass(studentId);
    }
    
    final List data = decoded as List;
    print('✅ Parsed ${data.length} sections with attendance data');
    
    if (data.isEmpty) {
      print('⚠️ Empty list - trying fallback: get sections by class');
      return await _getSectionsByClass(studentId);
    }
    
    return data.map((e) => SectionDto.fromJson(e)).toList();
  }

  // Fallback: Lấy sections theo class của sinh viên (không cần attendance)
  Future<List<SectionDto>> _getSectionsByClass(int studentId) async {
    print('🔄 Fallback: Fetching sections by student class...');
    try {
      // Bước 1: Lấy thông tin sinh viên để biết classId
      final studentUri = Uri.parse('${ApiClient.baseUrl}/api/students/$studentId');
      print('📞 Calling student API: $studentUri');
      
      final studentRes = await http.get(studentUri, headers: ApiClient.jsonHeaders).timeout(
        const Duration(seconds: 10),
      );
      
      if (studentRes.statusCode != 200) {
        print('⚠️ Failed to get student info: ${studentRes.statusCode}');
        return [];
      }
      
      final studentData = json.decode(studentRes.body);
      final classId = studentData['classId'] ?? studentData['class_id'];
      
      if (classId == null) {
        print('⚠️ Student has no classId');
        return [];
      }
      
      print('✅ Student classId: $classId');
      
      // Bước 2: Lấy tất cả sections và filter theo classId
      final allSectionsUri = Uri.parse('${ApiClient.baseUrl}/api/course-sections');
      print('📞 Calling all sections API: $allSectionsUri');
      
      final sectionsRes = await http.get(allSectionsUri, headers: ApiClient.jsonHeaders).timeout(
        const Duration(seconds: 30),
      );
      
      if (sectionsRes.statusCode != 200) {
        print('⚠️ Failed to get all sections: ${sectionsRes.statusCode}');
        return [];
      }
      
      final decoded = json.decode(sectionsRes.body);
      if (decoded == null || decoded is! List) {
        print('⚠️ Invalid sections data');
        return [];
      }
      
      final List allSections = decoded as List;
      print('📋 Found ${allSections.length} total sections');
      
      // Debug: In ra một vài sections đầu tiên để xem structure
      if (allSections.isNotEmpty) {
        print('📋 First section structure: ${allSections[0]}');
        // Kiểm tra các field có thể có
        final firstSection = allSections[0] as Map<String, dynamic>;
        print('📋 First section keys: ${firstSection.keys.toList()}');
        print('📋 First section classId (classId): ${firstSection['classId']}');
        print('📋 First section classId (class_id): ${firstSection['class_id']}');
        print('📋 First section classId (classId as int): ${firstSection['classId']?.runtimeType}');
      }
      
      // Filter sections theo classId - thử nhiều cách
      print('🔍 Filtering sections by classId: $classId');
      final studentSections = allSections
          .where((s) {
            final section = s as Map<String, dynamic>;
            // Thử nhiều cách lấy classId
            dynamic sectionClassId = section['classId'] ?? 
                                     section['class_id'] ?? 
                                     section['ClassId'];
            
            if (sectionClassId == null) {
              print('⚠️ Section ${section['sectionId']} has no classId');
              return false;
            }
            
            // Convert sang int
            int? classIdInt;
            if (sectionClassId is int) {
              classIdInt = sectionClassId;
            } else if (sectionClassId is num) {
              classIdInt = sectionClassId.toInt();
            } else if (sectionClassId is String) {
              classIdInt = int.tryParse(sectionClassId);
            }
            
            // Convert student classId sang int nếu cần
            int? studentClassIdInt;
            if (classId is int) {
              studentClassIdInt = classId;
            } else if (classId is num) {
              studentClassIdInt = classId.toInt();
            } else if (classId is String) {
              studentClassIdInt = int.tryParse(classId.toString());
            } else {
              studentClassIdInt = classId as int?;
            }
            
            final match = classIdInt != null && 
                         studentClassIdInt != null && 
                         classIdInt == studentClassIdInt;
            
            if (match) {
              print('✅ Found matching section: sectionId=${section['sectionId']}, sectionClassId=$classIdInt, studentClassId=$studentClassIdInt');
            } else {
              print('❌ Section ${section['sectionId']} - sectionClassId=$classIdInt, studentClassId=$studentClassIdInt - NO MATCH');
            }
            
            return match;
          })
          .map((e) {
            try {
              return SectionDto.fromJson(e);
            } catch (ex) {
              print('❌ Error parsing section in fallback: $ex');
              print('❌ Section data: $e');
              return null;
            }
          })
          .whereType<SectionDto>()
          .toList();
      
      print('✅ Found ${studentSections.length} sections for classId: $classId');
      
      // Nếu không tìm thấy sections theo classId, thử lấy tất cả sections (không filter)
      // Vì có thể student đang học nhiều lớp khác nhau
      if (studentSections.isEmpty) {
        print('⚠️ No sections found by classId, trying to get all sections without filter...');
        try {
          final allSectionsDto = allSections
              .map((e) {
                try {
                  return SectionDto.fromJson(e);
                } catch (ex) {
                  print('❌ Error parsing section: $ex');
                  return null;
                }
              })
              .whereType<SectionDto>()
              .toList();
          
          print('📦 Found ${allSectionsDto.length} total sections (no filter)');
          // Trả về tất cả sections nếu không tìm thấy theo classId
          // Có thể student đang học nhiều lớp hoặc classId không khớp
          return allSectionsDto;
        } catch (e) {
          print('❌ Error getting all sections: $e');
          return [];
        }
      }
      
      return studentSections;
    } catch (e) {
      print('❌ Fallback failed: $e');
      return [];
    }
  }
}

