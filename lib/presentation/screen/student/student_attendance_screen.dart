import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/api_client.dart';
import '../../../data/model/student_attendance_view.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final int sectionId;
  final String subjectName;
  final int studentId;

  const StudentAttendanceScreen({
    super.key,
    required this.sectionId,
    required this.subjectName,
    required this.studentId,
  });

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  late Future<List<StudentAttendanceView>> _futureAttendance;

  @override
  void initState() {
    super.initState();
    print('🔍 Loading attendance: studentId=${widget.studentId}, sectionId=${widget.sectionId}');
    _futureAttendance = _fetchAttendanceWithSessions(widget.studentId, widget.sectionId);
  }

  // Lấy tất cả sessions của section và merge với attendance records
  Future<List<StudentAttendanceView>> _fetchAttendanceWithSessions(int studentId, int sectionId) async {
    print('🔍 ===== START FETCHING ATTENDANCE =====');
    print('🔍 studentId: $studentId, sectionId: $sectionId');
    try {
      // Bước 1: Lấy tất cả sessions của section
      print('📞 Step 1: Fetching all sessions for section $sectionId');
      final sessionsUri = Uri.parse('${ApiClient.baseUrl}/api/sessions/course-section/$sectionId/all');
      print('📞 Calling API: $sessionsUri');
      
      final sessionsRes = await http.get(sessionsUri, headers: ApiClient.jsonHeaders).timeout(
        const Duration(seconds: 30),
      );
      
      print('📥 Sessions response status: ${sessionsRes.statusCode}');
      print('📥 Sessions response body length: ${sessionsRes.body.length} chars');
      
      List<Map<String, dynamic>> allSessions = [];
      if (sessionsRes.statusCode == 200 && sessionsRes.body.trim().isNotEmpty && sessionsRes.body.trim() != '[]') {
        final sessionsDecoded = json.decode(sessionsRes.body);
        if (sessionsDecoded is List) {
          allSessions = sessionsDecoded.cast<Map<String, dynamic>>();
          print('✅ Found ${allSessions.length} sessions in section $sectionId');
          // Log tất cả sessionIds để debug
          final sessionIds = allSessions.map((s) => (s['sessionId'] as num?)?.toInt()).where((id) => id != null).toList();
          print('📋 Session IDs in section $sectionId: $sessionIds');
          
          // Log chi tiết từng session để debug
          for (var session in allSessions) {
            final sessionId = (session['sessionId'] as num?)?.toInt();
            final date = session['date'];
            final label = session['label'];
            print('📋 Session detail - sessionId: $sessionId, date: $date, label: $label');
          }
        }
      } else {
        print('⚠️ No sessions found or API error for section $sectionId');
        print('📥 Response body: ${sessionsRes.body}');
      }
      
      // Bước 2: Lấy attendance records của student trong section này
      print('📞 Step 2: Fetching attendance records for student $studentId in section $sectionId');
      
      Map<int, Map<String, dynamic>> attendanceMap = {};
      
      // PHƯƠNG PHÁP MỚI: Lấy attendance từ từng session trong section
      // Thay vì gọi endpoint /api/attendances/student/{studentId}/section/{sectionId},
      // sẽ gọi /api/attendances?sessionId={sessionId} cho từng session và filter client-side
      print('📞 Step 2.1: Fetching attendances from each session in section $sectionId');
      
      // Lấy attendances từ tất cả sessions trong section
      for (var session in allSessions) {
        final sessionId = (session['sessionId'] as num?)?.toInt();
        if (sessionId == null) continue;
        
        try {
          final sessionAttendanceUri = Uri.parse('${ApiClient.baseUrl}/api/attendances')
              .replace(queryParameters: {'sessionId': sessionId.toString()});
          print('📞 Fetching attendances for session $sessionId: $sessionAttendanceUri');
          
          final sessionAttendanceRes = await http.get(sessionAttendanceUri, headers: ApiClient.jsonHeaders).timeout(
            const Duration(seconds: 10),
          );
          
          print('📥 Response status: ${sessionAttendanceRes.statusCode}');
          print('📥 Response body length: ${sessionAttendanceRes.body.length} chars');
          
          if (sessionAttendanceRes.statusCode == 200 && sessionAttendanceRes.body.trim().isNotEmpty && sessionAttendanceRes.body.trim() != '[]') {
            final sessionAttendanceDecoded = json.decode(sessionAttendanceRes.body);
            print('📋 Decoded type: ${sessionAttendanceDecoded.runtimeType}');
            
            if (sessionAttendanceDecoded is List && sessionAttendanceDecoded.isNotEmpty) {
              print('✅ Found ${sessionAttendanceDecoded.length} attendances for session $sessionId');
              
              // Log tất cả studentIds trong session để debug
              final allStudentIds = sessionAttendanceDecoded
                  .map((att) => (att as Map<String, dynamic>)['studentId'])
                  .whereType<int>()
                  .toList();
              print('📋 All studentIds in session $sessionId: $allStudentIds');
              
              // Tìm attendance cho student này
              bool found = false;
              for (var att in sessionAttendanceDecoded) {
                final attMap = att as Map<String, dynamic>;
                final attStudentId = (attMap['studentId'] as num?)?.toInt();
                final attStatus = attMap['status'];
                print('📋 Checking attendance: studentId=$attStudentId, status=$attStatus, target studentId=$studentId');
                
                if (attStudentId == studentId) {
                  print('✅ Found attendance for student $studentId in session $sessionId!');
                  print('📋 Attendance data: $attMap');
                  attendanceMap[sessionId] = attMap;
                  found = true;
                  break;
                }
              }
              
              if (!found) {
                print('⚠️ Student $studentId NOT found in ${sessionAttendanceDecoded.length} attendances for session $sessionId');
                print('⚠️ Available studentIds: $allStudentIds');
              }
            } else {
              print('⚠️ Response is not a List or empty');
            }
          } else {
            print('⚠️ API returned empty for session $sessionId (status: ${sessionAttendanceRes.statusCode})');
            if (sessionAttendanceRes.body.trim().isNotEmpty) {
              print('📥 Response body: ${sessionAttendanceRes.body}');
            }
          }
        } catch (e) {
          print('⚠️ Failed to get attendance for session $sessionId: $e');
        }
      }
      
      print('✅ Step 2.1: Found ${attendanceMap.length} attendances from sessions in section $sectionId');
      
      // Thử 1: Endpoint /api/attendances/student/{studentId}/section/{sectionId} (fallback)
      if (attendanceMap.isEmpty) {
        print('📞 Step 2.2: Trying fallback endpoint /api/attendances/student/$studentId/section/$sectionId');
        final attendanceUri = Uri.parse('${ApiClient.baseUrl}/api/attendances/student/$studentId/section/$sectionId');
        print('📞 Trying API: $attendanceUri');
        
        final attendanceRes = await http.get(attendanceUri, headers: ApiClient.jsonHeaders).timeout(
          const Duration(seconds: 30),
        );
        
        print('📥 Attendance response status: ${attendanceRes.statusCode}');
        print('📥 Attendance response body length: ${attendanceRes.body.length} chars');
        print('📥 Attendance response body: ${attendanceRes.body}');
        
        // Nếu status không phải 200, log error
        if (attendanceRes.statusCode != 200) {
          print('⚠️ Main endpoint returned status ${attendanceRes.statusCode}');
          final errorPreview = attendanceRes.body.length > 500 ? attendanceRes.body.substring(0, 500) : attendanceRes.body;
          print('📥 Error response preview: $errorPreview');
        }
        
        if (attendanceRes.statusCode == 200 && attendanceRes.body.trim().isNotEmpty && attendanceRes.body.trim() != '[]') {
          final attendanceDecoded = json.decode(attendanceRes.body);
          if (attendanceDecoded is List) {
            final List attendanceList = attendanceDecoded;
            print('✅ Found ${attendanceList.length} attendance records from main endpoint');
            // Tạo map: sessionId -> attendance record
            for (var att in attendanceList) {
              final attMap = att as Map<String, dynamic>;
              final sessionId = (attMap['sessionId'] as num?)?.toInt();
              print('📋 Attendance record: sessionId=$sessionId, keys=${attMap.keys.toList()}');
              if (sessionId != null) {
                attendanceMap[sessionId] = attMap;
                print('✅ Mapped attendance: sessionId=$sessionId -> attendance record');
              } else {
                print('⚠️ Attendance record has no sessionId: $attMap');
              }
            }
          } else {
            print('⚠️ Attendance response is not a List: ${attendanceDecoded.runtimeType}');
          }
        } else {
          print('⚠️ Main endpoint returned empty (status: ${attendanceRes.statusCode}, body: ${attendanceRes.body})');
          
          // Thử 2: Lấy tất cả attendances của student và filter theo sectionId
          print('📞 Trying fallback: Get all attendances for student and filter by section');
          try {
            // Thử endpoint /api/attendances/student/{studentId} - có thể không tồn tại
            // Nếu không được, sẽ thử lấy từ tất cả sessions
            final allAttendancesUri = Uri.parse('${ApiClient.baseUrl}/api/attendances/student/$studentId');
            print('📞 Calling API: $allAttendancesUri');
            
            final allAttendancesRes = await http.get(allAttendancesUri, headers: ApiClient.jsonHeaders).timeout(
              const Duration(seconds: 30),
            );
            
            print('📥 All attendances response status: ${allAttendancesRes.statusCode}');
            print('📥 All attendances response body length: ${allAttendancesRes.body.length} chars');
            
            if (allAttendancesRes.statusCode == 200 && allAttendancesRes.body.trim().isNotEmpty && allAttendancesRes.body.trim() != '[]') {
              final allAttendancesDecoded = json.decode(allAttendancesRes.body);
              if (allAttendancesDecoded is List) {
                final List allAttendancesList = allAttendancesDecoded;
                print('✅ Found ${allAttendancesList.length} total attendances for student');
                
                // Filter theo sectionId từ sessions
                final sessionIdsInSection = allSessions.map((s) => (s['sessionId'] as num?)?.toInt()).whereType<int>().toSet();
                print('📋 SessionIds in section: $sessionIdsInSection');
                
                for (var att in allAttendancesList) {
                  final attMap = att as Map<String, dynamic>;
                  final sessionId = (attMap['sessionId'] as num?)?.toInt();
                  if (sessionId != null && sessionIdsInSection.contains(sessionId)) {
                    print('✅ Found attendance for session $sessionId in section $sectionId');
                    attendanceMap[sessionId] = attMap;
                  }
                }
                
                print('✅ After filtering: ${attendanceMap.length} attendances match section $sectionId');
              } else {
                print('⚠️ All attendances response is not a List or empty');
              }
            } else {
              print('⚠️ All attendances endpoint returned status ${allAttendancesRes.statusCode} or empty');
            }
          } catch (e) {
            print('⚠️ Fallback endpoint failed: $e');
          }
        }
        
        // Thử 3: Lấy attendance từng session nếu vẫn không có
        if (attendanceMap.isEmpty && allSessions.isNotEmpty) {
          print('📞 Trying method 3: Get attendance for each session individually');
          print('📋 Checking ${allSessions.length} sessions for attendance records');
          
          // DEBUG: Thử lấy tất cả attendances của student để xem có attendance ở đâu
          print('🔍 DEBUG: Checking if student $studentId has any attendances at all...');
          List<Map<String, dynamic>> allStudentAttendances = [];
          
          // Thử nhiều cách để lấy attendances của student
          // Cách 1: /api/attendances?studentId={studentId}
          try {
            final allStudentAttendancesUri = Uri.parse('${ApiClient.baseUrl}/api/attendances')
                .replace(queryParameters: {
                  'studentId': studentId.toString(),
                });
            print('📞 DEBUG: Trying method 1: $allStudentAttendancesUri');
            
            final allStudentAttendancesRes = await http.get(allStudentAttendancesUri, headers: ApiClient.jsonHeaders).timeout(
              const Duration(seconds: 10),
            );
            
            print('📥 DEBUG: Method 1 response status: ${allStudentAttendancesRes.statusCode}');
            print('📥 DEBUG: Method 1 response body length: ${allStudentAttendancesRes.body.length} chars');
            if (allStudentAttendancesRes.statusCode != 200) {
              print('📥 DEBUG: Method 1 error response: ${allStudentAttendancesRes.body.substring(0, allStudentAttendancesRes.body.length > 500 ? 500 : allStudentAttendancesRes.body.length)}');
            }
            
            if (allStudentAttendancesRes.statusCode == 200 && allStudentAttendancesRes.body.trim().isNotEmpty && allStudentAttendancesRes.body.trim() != '[]') {
              final allStudentAttendancesDecoded = json.decode(allStudentAttendancesRes.body);
              if (allStudentAttendancesDecoded is List) {
                allStudentAttendances = allStudentAttendancesDecoded.cast<Map<String, dynamic>>();
                print('✅ DEBUG: Method 1 found ${allStudentAttendances.length} attendances');
              }
            } else {
              print('⚠️ DEBUG: Method 1 returned empty (status: ${allStudentAttendancesRes.statusCode})');
            }
          } catch (e) {
            print('⚠️ DEBUG: Method 1 failed: $e');
          }
          
          // Cách 2: /api/attendances/student/{studentId} (nếu method 1 không có dữ liệu)
          if (allStudentAttendances.isEmpty) {
            try {
              final allStudentAttendancesUri2 = Uri.parse('${ApiClient.baseUrl}/api/attendances/student/$studentId');
              print('📞 DEBUG: Trying method 2: $allStudentAttendancesUri2');
              
              final allStudentAttendancesRes2 = await http.get(allStudentAttendancesUri2, headers: ApiClient.jsonHeaders).timeout(
                const Duration(seconds: 10),
              );
              
              print('📥 DEBUG: Method 2 response status: ${allStudentAttendancesRes2.statusCode}');
              print('📥 DEBUG: Method 2 response body length: ${allStudentAttendancesRes2.body.length} chars');
              
              if (allStudentAttendancesRes2.statusCode == 200 && allStudentAttendancesRes2.body.trim().isNotEmpty && allStudentAttendancesRes2.body.trim() != '[]') {
                final allStudentAttendancesDecoded2 = json.decode(allStudentAttendancesRes2.body);
                if (allStudentAttendancesDecoded2 is List) {
                  allStudentAttendances = allStudentAttendancesDecoded2.cast<Map<String, dynamic>>();
                  print('✅ DEBUG: Method 2 found ${allStudentAttendances.length} attendances');
                }
              } else {
                print('⚠️ DEBUG: Method 2 returned empty (status: ${allStudentAttendancesRes2.statusCode})');
              }
            } catch (e) {
              print('⚠️ DEBUG: Method 2 failed: $e');
            }
          }
          
          // Nếu có attendances, log và match với sessions
          if (allStudentAttendances.isNotEmpty) {
            print('🔍 DEBUG: Student $studentId has ${allStudentAttendances.length} total attendances');
            for (var att in allStudentAttendances) {
              final attSessionId = (att['sessionId'] as num?)?.toInt();
              final attStatus = att['status'];
              final attSectionId = (att['sectionId'] as num?)?.toInt();
              print('🔍 DEBUG: Attendance found - sessionId: $attSessionId, sectionId: $attSectionId, status: $attStatus');
            }
            
            // Match với sessions trong section
            final sectionSessionIds = allSessions.map((s) => (s['sessionId'] as num?)?.toInt()).whereType<int>().toSet();
            print('🔍 DEBUG: Section $sectionId has sessions: $sectionSessionIds');
            
            // Log tất cả attendances của student để xem có match không
            final studentSessionIds = allStudentAttendances
                .map((att) => (att['sessionId'] as num?)?.toInt())
                .whereType<int>()
                .toList();
            print('🔍 DEBUG: Student attendances are in sessions: $studentSessionIds');
            
            // Tìm sessions có attendance nhưng không có trong section
            final missingSessions = studentSessionIds.where((sid) => !sectionSessionIds.contains(sid)).toList();
            if (missingSessions.isNotEmpty) {
              print('⚠️ DEBUG: Student has attendances in sessions $missingSessions, but these sessions are NOT in section $sectionId!');
              print('⚠️ DEBUG: Section $sectionId only has sessions: $sectionSessionIds');
            }
            
            for (var att in allStudentAttendances) {
              final attSessionId = (att['sessionId'] as num?)?.toInt();
              if (attSessionId != null && sectionSessionIds.contains(attSessionId)) {
                print('✅ DEBUG: Found matching attendance for session $attSessionId in section $sectionId!');
                attendanceMap[attSessionId] = att;
              }
            }
            
            if (attendanceMap.isNotEmpty) {
              print('✅ DEBUG: Found ${attendanceMap.length} attendances by matching with section sessions!');
            } else {
              print('⚠️ DEBUG: Student has attendances but NONE match section $sectionId sessions');
              if (missingSessions.isNotEmpty) {
                print('⚠️ DEBUG: Có thể section $sectionId thiếu sessions $missingSessions');
              }
            }
          } else {
            print('🔍 DEBUG: Student $studentId has NO attendances at all');
          }
          
          // Thử lấy attendance từ các sessions có thể có attendance (từ session 1 đến 240)
          // Nếu section chỉ có session 4 nhưng student có attendance ở session 5, sẽ không match
          // Nên thử lấy attendance từ tất cả sessions có thể trong section
          print('🔍 Checking attendance for all sessions in section $sectionId...');
          
          // Nếu allStudentAttendances đã có, thử match lại với sessions
          if (allStudentAttendances.isNotEmpty) {
            print('🔍 Re-checking ${allStudentAttendances.length} attendances against ${allSessions.length} sessions...');
            final sectionSessionIds = allSessions.map((s) => (s['sessionId'] as num?)?.toInt()).whereType<int>().toSet();
            for (var att in allStudentAttendances) {
              final attSessionId = (att['sessionId'] as num?)?.toInt();
              if (attSessionId != null && sectionSessionIds.contains(attSessionId)) {
                print('✅ Found matching attendance for session $attSessionId!');
                attendanceMap[attSessionId] = att;
              }
            }
          }
          
          for (var session in allSessions) {
            final sessionId = (session['sessionId'] as num?)?.toInt();
            if (sessionId == null) {
              print('⚠️ Session has no sessionId: $session');
              continue;
            }
            
            // Nếu đã có attendance trong map, skip
            if (attendanceMap.containsKey(sessionId)) {
              print('✅ Session $sessionId already has attendance in map, skipping...');
              continue;
            }
            
            print('🔍 Checking session $sessionId for student $studentId...');
            
            try {
              // Thử 3a: Endpoint /api/attendances?sessionId={sessionId} (KHÔNG có studentId)
              // Backend có thể không hỗ trợ filter theo studentId, nên lấy tất cả attendances của session rồi filter client-side
              final sessionAttendanceUri = Uri.parse('${ApiClient.baseUrl}/api/attendances')
                  .replace(queryParameters: {
                    'sessionId': sessionId.toString(),
                    // KHÔNG thêm studentId vào query params
                  });
              print('📞 Trying API (without studentId): $sessionAttendanceUri');
              
              final sessionAttendanceRes = await http.get(sessionAttendanceUri, headers: ApiClient.jsonHeaders).timeout(
                const Duration(seconds: 10),
              );
              
              print('📥 Response status: ${sessionAttendanceRes.statusCode}');
              print('📥 Response body length: ${sessionAttendanceRes.body.length} chars');
              
              if (sessionAttendanceRes.statusCode == 200 && sessionAttendanceRes.body.trim().isNotEmpty && sessionAttendanceRes.body.trim() != '[]') {
                final sessionAttendanceDecoded = json.decode(sessionAttendanceRes.body);
                print('📋 Response decoded type: ${sessionAttendanceDecoded.runtimeType}');
                
                // Nếu response là một object (single attendance), check studentId
                if (sessionAttendanceDecoded is Map<String, dynamic>) {
                  final attStudentId = (sessionAttendanceDecoded['studentId'] as num?)?.toInt();
                  final attSessionId = (sessionAttendanceDecoded['sessionId'] as num?)?.toInt();
                  print('📋 Single attendance: studentId=$attStudentId, sessionId=$attSessionId, target studentId=$studentId');
                  if (attStudentId == studentId && attSessionId == sessionId) {
                    print('✅ Found attendance for session $sessionId, student $studentId');
                    print('📋 Attendance data: $sessionAttendanceDecoded');
                    attendanceMap[sessionId] = sessionAttendanceDecoded;
                  }
                } 
                // Nếu response là một list, tìm attendance cho student này
                else if (sessionAttendanceDecoded is List && sessionAttendanceDecoded.isNotEmpty) {
                  print('✅ Found ${sessionAttendanceDecoded.length} attendances for session $sessionId');
                  print('🔍 Looking for student $studentId in ${sessionAttendanceDecoded.length} attendances...');
                  
                  // Log tất cả studentIds để debug
                  final allStudentIds = sessionAttendanceDecoded
                      .map((att) => (att as Map<String, dynamic>)['studentId'])
                      .whereType<int>()
                      .toList();
                  print('📋 All studentIds in session $sessionId: $allStudentIds');
                  
                  // Tìm attendance record cho student này
                  bool found = false;
                  for (var att in sessionAttendanceDecoded) {
                    final attMap = att as Map<String, dynamic>;
                    final attStudentId = (attMap['studentId'] as num?)?.toInt();
                    print('📋 Checking attendance: studentId=$attStudentId, target studentId=$studentId');
                    if (attStudentId == studentId) {
                      print('✅ Found attendance for session $sessionId, student $studentId');
                      print('📋 Attendance data: $attMap');
                      attendanceMap[sessionId] = attMap;
                      found = true;
                      break;
                    }
                  }
                  if (!found) {
                    print('⚠️ Student $studentId NOT found in ${sessionAttendanceDecoded.length} attendances for session $sessionId');
                    print('⚠️ Available studentIds: $allStudentIds');
                  }
                } else {
                  print('⚠️ No attendances found for session $sessionId');
                }
              } else {
                print('⚠️ API returned empty for session $sessionId (status: ${sessionAttendanceRes.statusCode})');
                print('📥 Response body: ${sessionAttendanceRes.body}');
                
                // Nếu empty, có thể session này chưa có attendance records
                // Nhưng vẫn cần log để debug
                if (sessionAttendanceRes.statusCode == 200 && sessionAttendanceRes.body.trim() == '[]') {
                  print('ℹ️ Session $sessionId has no attendance records yet (empty array)');
                }
              }
            } catch (e) {
              print('⚠️ Failed to get attendance for session $sessionId: $e');
            }
          }
          
          print('✅ After method 3: ${attendanceMap.length} attendances found out of ${allSessions.length} sessions');
        }
      }
      
      // Bước 3: Merge sessions với attendance records
      print('📞 Step 3: Merging ${allSessions.length} sessions with ${attendanceMap.length} attendance records');
      print('📋 Attendance map keys: ${attendanceMap.keys.toList()}');
      
      // DEBUG: Kiểm tra lại tất cả attendances của student để xem có attendance ở session nào
      print('🔍 ===== FINAL DEBUG CHECK =====');
      print('🔍 Section $sectionId has sessions: ${allSessions.map((s) => (s['sessionId'] as num?)?.toInt()).whereType<int>().toList()}');
      print('🔍 Found attendances for sessions: ${attendanceMap.keys.toList()}');
      
      // Kiểm tra xem có attendance records nào bị miss không
      if (attendanceMap.isEmpty && allSessions.isNotEmpty) {
        print('⚠️ WARNING: No attendances found, but section has ${allSessions.length} sessions');
        print('🔍 FINAL CHECK: Checking if student $studentId has attendances in other sessions...');
        
        // Thử lấy tất cả attendances của student (không filter theo section)
        List<Map<String, dynamic>> finalCheckAttendances = [];
        
        // Thử method 1: /api/attendances?studentId={studentId}
        try {
          final allStudentAttUri = Uri.parse('${ApiClient.baseUrl}/api/attendances')
              .replace(queryParameters: {'studentId': studentId.toString()});
          print('📞 FINAL CHECK Method 1: $allStudentAttUri');
          
          final allStudentAttRes = await http.get(allStudentAttUri, headers: ApiClient.jsonHeaders).timeout(
            const Duration(seconds: 10),
          );
          
          print('📥 FINAL CHECK Method 1 response status: ${allStudentAttRes.statusCode}');
          print('📥 FINAL CHECK Method 1 response body length: ${allStudentAttRes.body.length} chars');
          if (allStudentAttRes.statusCode != 200) {
            final errorBody = allStudentAttRes.body.length > 500 ? allStudentAttRes.body.substring(0, 500) : allStudentAttRes.body;
            print('📥 FINAL CHECK Method 1 error response: $errorBody');
          }
          
          if (allStudentAttRes.statusCode == 200 && allStudentAttRes.body.trim().isNotEmpty && allStudentAttRes.body.trim() != '[]') {
            final allStudentAttDecoded = json.decode(allStudentAttRes.body);
            if (allStudentAttDecoded is List) {
              finalCheckAttendances = allStudentAttDecoded.cast<Map<String, dynamic>>();
              print('✅ FINAL CHECK Method 1 found ${finalCheckAttendances.length} attendances');
            }
          } else {
            print('⚠️ FINAL CHECK Method 1 returned empty');
          }
        } catch (e) {
          print('⚠️ FINAL CHECK Method 1 failed: $e');
        }
        
        // Thử method 2: /api/attendances/student/{studentId}
        if (finalCheckAttendances.isEmpty) {
          try {
            final allStudentAttUri2 = Uri.parse('${ApiClient.baseUrl}/api/attendances/student/$studentId');
            print('📞 FINAL CHECK Method 2: $allStudentAttUri2');
            
            final allStudentAttRes2 = await http.get(allStudentAttUri2, headers: ApiClient.jsonHeaders).timeout(
              const Duration(seconds: 10),
            );
            
            print('📥 FINAL CHECK Method 2 response status: ${allStudentAttRes2.statusCode}');
            print('📥 FINAL CHECK Method 2 response body length: ${allStudentAttRes2.body.length} chars');
            
            if (allStudentAttRes2.statusCode == 200 && allStudentAttRes2.body.trim().isNotEmpty && allStudentAttRes2.body.trim() != '[]') {
              final allStudentAttDecoded2 = json.decode(allStudentAttRes2.body);
              if (allStudentAttDecoded2 is List) {
                finalCheckAttendances = allStudentAttDecoded2.cast<Map<String, dynamic>>();
                print('✅ FINAL CHECK Method 2 found ${finalCheckAttendances.length} attendances');
              }
            } else {
              print('⚠️ FINAL CHECK Method 2 returned empty');
            }
          } catch (e) {
            print('⚠️ FINAL CHECK Method 2 failed: $e');
          }
        }
        
        // Nếu có attendances, match lại với sessions
        if (finalCheckAttendances.isNotEmpty) {
          print('🔍 FINAL CHECK: Student $studentId has ${finalCheckAttendances.length} attendances in total');
          final studentSessionIds = finalCheckAttendances
              .map((att) => (att['sessionId'] as num?)?.toInt())
              .whereType<int>()
              .toList();
          print('🔍 FINAL CHECK: Student attendances are in sessions: $studentSessionIds');
          
          final sectionSessionIds = allSessions.map((s) => (s['sessionId'] as num?)?.toInt()).whereType<int>().toList();
          print('🔍 FINAL CHECK: Section sessions are: $sectionSessionIds');
          
          // Log chi tiết từng attendance
          for (var att in finalCheckAttendances) {
            final attSessionId = (att['sessionId'] as num?)?.toInt();
            final attSectionId = (att['sectionId'] as num?)?.toInt();
            final attStatus = att['status'];
            print('🔍 FINAL CHECK: Attendance - sessionId: $attSessionId, sectionId: $attSectionId, status: $attStatus');
            
            // Nếu attendance có sessionId trong section, thêm vào map
            if (attSessionId != null && sectionSessionIds.contains(attSessionId)) {
              print('✅ FINAL CHECK: Found matching attendance for session $attSessionId! Adding to map...');
              attendanceMap[attSessionId] = att;
            }
          }
          
          if (attendanceMap.isNotEmpty) {
            print('✅ FINAL CHECK: Found ${attendanceMap.length} attendances by matching!');
          } else {
            final missingSessions = studentSessionIds.where((sid) => !sectionSessionIds.contains(sid)).toList();
            if (missingSessions.isNotEmpty) {
              print('⚠️ FINAL CHECK: Student has attendances in sessions $missingSessions, but these sessions are NOT in section $sectionId!');
              print('⚠️ FINAL CHECK: Section $sectionId has sessions $sectionSessionIds (max: ${sectionSessionIds.isNotEmpty ? sectionSessionIds.reduce((a, b) => a > b ? a : b) : 'N/A'})');
              print('⚠️ FINAL CHECK: Student attendances are in sessions $studentSessionIds (max: ${studentSessionIds.isNotEmpty ? studentSessionIds.reduce((a, b) => a > b ? a : b) : 'N/A'})');
              print('⚠️ FINAL CHECK: Có thể section $sectionId có sessions mới (258-270) nhưng DB chỉ có attendance đến sessionId 240');
            } else {
              print('⚠️ FINAL CHECK: No attendances match section sessions');
            }
          }
        } else {
          print('🔍 FINAL CHECK: Student $studentId has NO attendances at all');
          print('⚠️ FINAL CHECK: Có thể section $sectionId có sessions mới (258-270) nhưng DB chỉ có attendance đến sessionId 240');
        }
      }
      
      List<StudentAttendanceView> result = [];
      
      // Ưu tiên: Nếu có attendance records, hiển thị chúng trước (không cần merge với sessions)
      // Chỉ merge nếu cần hiển thị sessions chưa có attendance
      if (attendanceMap.isNotEmpty) {
        print('📋 Priority: Using attendance records directly');
        // Tạo map từ attendance records để check duplicate
        final Map<int, StudentAttendanceView> attendanceResultMap = {};
        for (var attendance in attendanceMap.values) {
          final view = _mapToStudentAttendanceView(attendance);
          attendanceResultMap[view.sessionId] = view;
        }
        
        // Thêm sessions chưa có attendance
        for (var session in allSessions) {
          final sessionId = (session['sessionId'] as num?)?.toInt();
          if (sessionId != null && !attendanceResultMap.containsKey(sessionId)) {
            attendanceResultMap[sessionId] = _mapSessionToAttendanceView(session, studentId);
          }
        }
        
        result = attendanceResultMap.values.toList();
      } else {
        // Nếu không có attendance records, chỉ hiển thị sessions
        print('⚠️ No attendance records found - showing all sessions as NOT_MARKED');
        for (var session in allSessions) {
          final sessionId = (session['sessionId'] as num?)?.toInt();
          if (sessionId != null) {
            result.add(_mapSessionToAttendanceView(session, studentId));
          }
        }
      }
      
      // Sắp xếp theo date
      result.sort((a, b) {
        if (a.date == null || b.date == null) return 0;
        try {
          // Parse date từ "dd/MM/yyyy" hoặc "yyyy-MM-dd"
          final aDate = _parseDate(a.date!);
          final bDate = _parseDate(b.date!);
          if (aDate != null && bDate != null) {
            return aDate.compareTo(bDate);
          }
        } catch (e) {
          print('⚠️ Error sorting by date: $e');
        }
        return 0;
      });
      
      print('✅ Final result: ${result.length} attendance views');
      print('📋 Status breakdown:');
      final presentCount = result.where((r) => r.status == 'PRESENT').length;
      final absentCount = result.where((r) => r.status == 'ABSENT').length;
      final notMarkedCount = result.where((r) => r.status == 'NOT_MARKED').length;
      print('   - PRESENT: $presentCount');
      print('   - ABSENT: $absentCount');
      print('   - NOT_MARKED: $notMarkedCount');
      
      return result;
      
    } catch (e) {
      print('❌ Error in _fetchAttendanceWithSessions: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      // Fallback: Chỉ lấy attendance records
      return await _fetchAttendanceOnly(studentId, sectionId);
    }
  }

  // Fallback: Chỉ lấy attendance records (không có sessions)
  Future<List<StudentAttendanceView>> _fetchAttendanceOnly(int studentId, int sectionId) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/api/attendances/student/$studentId/section/$sectionId');
    print('📞 Fallback: Calling API: $uri');
    
    final res = await http.get(uri, headers: ApiClient.jsonHeaders).timeout(
      const Duration(seconds: 30),
    );
    
    if (res.statusCode != 200) {
      if (res.statusCode == 404) {
        return [];
      }
      throw Exception('GET student attendance failed: ${res.statusCode} ${res.body}');
    }
    
    if (res.body.trim().isEmpty || res.body.trim() == 'null' || res.body.trim() == '[]') {
      return [];
    }
    
    final decoded = json.decode(res.body);
    if (decoded == null || decoded is! List) {
      return [];
    }
    
    final List data = decoded as List;
    return data.map((e) => _mapToStudentAttendanceView(e)).toList();
  }

  // Map session (không có attendance) thành StudentAttendanceView với status "NOT_MARKED"
  StudentAttendanceView _mapSessionToAttendanceView(Map<String, dynamic> session, int studentId) {
    return StudentAttendanceView(
      sessionId: (session['sessionId'] as num?)?.toInt() ?? 0,
      studentId: studentId,
      studentName: '', // Sẽ không hiển thị tên khi chưa điểm danh
      status: 'NOT_MARKED', // Status mới cho chưa điểm danh
      date: _formatDate(session['date']),
      startTime: _formatTime(session['startTime']),
      endTime: _formatTime(session['endTime']),
      classroom: session['classroom'] as String?,
      label: session['label'] as String?,
      markedAt: null,
      note: null,
    );
  }

  // Parse date từ "dd/MM/yyyy" hoặc "yyyy-MM-dd" thành DateTime để sort
  DateTime? _parseDate(String dateStr) {
    try {
      if (dateStr.contains('/')) {
        // Format: "dd/MM/yyyy"
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      } else if (dateStr.contains('-')) {
        // Format: "yyyy-MM-dd"
        return DateTime.parse(dateStr);
      }
    } catch (e) {
      print('⚠️ Error parsing date: $dateStr, error: $e');
    }
    return null;
  }

  StudentAttendanceView _mapToStudentAttendanceView(Map<String, dynamic> json) {
    // Log để debug
    print('📋 Mapping attendance record: $json');
    print('📋 Keys: ${json.keys.toList()}');
    
    // Parse theo StudentAttendanceViewDTO từ backend
    // Backend DTO có: sessionId (Long), studentId (Long), studentName, status, date (LocalDate), 
    // startTime (LocalTime), endTime (LocalTime), classroom, label, markedAt, note
    
    final sessionId = (json['sessionId'] as num?)?.toInt() ?? 0;
    final studentId = (json['studentId'] as num?)?.toInt() ?? 0;
    final studentName = json['studentName'] as String? ?? '';
    final status = json['status'] as String? ?? 'UNKNOWN';
    
    print('📋 Parsed: sessionId=$sessionId, studentId=$studentId, studentName=$studentName, status=$status');
    print('📋 date: ${json['date']}, startTime: ${json['startTime']}, endTime: ${json['endTime']}');
    
    return StudentAttendanceView(
      sessionId: sessionId,
      studentId: studentId,
      studentName: studentName,
      status: status,
      date: _formatDate(json['date']),
      startTime: _formatTime(json['startTime']),
      endTime: _formatTime(json['endTime']),
      classroom: json['classroom'] as String?,
      label: json['label'] as String?,
      markedAt: json['markedAt'] as String?,
      note: json['note'] as String?,
    );
  }

  // Format LocalDate từ backend (VD: "2024-10-07") thành "07/10/2024"
  String? _formatDate(dynamic date) {
    if (date == null) return null;
    try {
      final dateStr = date.toString().trim();
      if (dateStr.isEmpty) return null;
      
      // Nếu đã có format "dd/MM/yyyy" thì giữ nguyên
      if (dateStr.contains('/')) {
        return dateStr;
      }
      
      // Parse từ "yyyy-MM-dd" (LocalDate format)
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = parts[1].padLeft(2, '0');
        final day = parts[2].padLeft(2, '0');
        return '$day/$month/$year';
      }
    } catch (e) {
      print('⚠️ Error formatting date: $date, error: $e');
    }
    return date.toString();
  }

  // Format LocalTime từ backend (VD: "07:00:00" hoặc "07:00") thành "07:00"
  String? _formatTime(dynamic time) {
    if (time == null) return null;
    try {
      final timeStr = time.toString().trim();
      if (timeStr.isEmpty) return null;
      
      // Nếu đã có format "HH:mm" thì giữ nguyên
      if (timeStr.length == 5 && timeStr.contains(':')) {
        return timeStr;
      }
      
      // Parse từ "HH:mm:ss" hoặc "HH:mm:ss.SSS" (LocalTime format)
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = parts[0].padLeft(2, '0');
        final minute = parts[1].padLeft(2, '0');
        return '$hour:$minute';
      }
    } catch (e) {
      print('⚠️ Error formatting time: $time, error: $e');
    }
    return time.toString();
  }
  
  Future<List<StudentAttendanceView>> _getMockAttendanceData() async {
    // Fake delay giống API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data - Điểm danh của 1 sinh viên qua các buổi học
    return [
      StudentAttendanceView(
        sessionId: 1,
        studentId: 1,
        studentName: 'Nguyễn Văn A',
        status: 'PRESENT',
        markedAt: '2024-10-07 07:15:00',
        date: '07/10/2024',
        startTime: '07:00',
        endTime: '09:30',
        classroom: 'TC-205',
        label: 'Buổi 1',
      ),
      StudentAttendanceView(
        sessionId: 2,
        studentId: 1,
        studentName: 'Nguyễn Văn A',
        status: 'PRESENT',
        markedAt: '2024-10-14 07:10:00',
        date: '14/10/2024',
        startTime: '07:00',
        endTime: '09:30',
        classroom: 'TC-205',
        label: 'Buổi 2',
      ),
      StudentAttendanceView(
        sessionId: 3,
        studentId: 1,
        studentName: 'Nguyễn Văn A',
        status: 'ABSENT',
        note: 'Ốm',
        date: '21/10/2024',
        startTime: '07:00',
        endTime: '09:30',
        classroom: 'TC-205',
        label: 'Buổi 3',
      ),
      StudentAttendanceView(
        sessionId: 4,
        studentId: 1,
        studentName: 'Nguyễn Văn A',
        status: 'PRESENT',
        markedAt: '2024-10-28 07:15:00',
        date: '28/10/2024',
        startTime: '07:00',
        endTime: '09:30',
        classroom: 'TC-205',
        label: 'Buổi 4',
      ),
      StudentAttendanceView(
        sessionId: 5,
        studentId: 1,
        studentName: 'Nguyễn Văn A',
        status: 'PRESENT',
        markedAt: '2024-11-04 07:05:00',
        date: '04/11/2024',
        startTime: '07:00',
        endTime: '09:30',
        classroom: 'TC-205',
        label: 'Buổi 5',
      ),
    ];
  }

  void _refresh() {
    setState(() {
      _futureAttendance = _fetchAttendanceWithSessions(widget.studentId, widget.sectionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subjectName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3A5BA0),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: FutureBuilder<List<StudentAttendanceView>>(
        future: _futureAttendance,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải dữ liệu điểm danh...'),
                ],
              ),
            );
          }

          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: ${snap.error}',
                      textAlign: TextAlign.center,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final attendanceList = snap.data ?? [];
          if (attendanceList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có dữ liệu điểm danh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Môn học: ${widget.subjectName}\nSection ID: ${widget.sectionId}\nStudent ID: ${widget.studentId}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Làm mới'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A5BA0),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Tính thống kê
          final present = attendanceList.where((a) => a.isPresent).length;
          final absent = attendanceList.where((a) => a.isAbsent).length;
          final total = attendanceList.length;
          final attendanceRate = total > 0 ? present / total * 100 : 0;

          return Column(
            children: [
              // Thống kê tổng quan
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A5BA0),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tỷ lệ điểm danh',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${attendanceRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$total buổi học',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Thống kê chi tiết với indicator tròn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatIndicator(true, present, 'Có mặt'),
                        _buildStatIndicator(false, absent, 'Vắng'),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Danh sách điểm danh
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: attendanceList.length,
                    itemBuilder: (context, index) {
                      final attendance = attendanceList[index];
                      final isPresent = attendance.isPresent;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header với icon checkmark xanh và trạng thái
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isPresent ? Colors.green : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isPresent ? Icons.check : Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          attendance.label ?? 'Buổi ${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2D3748),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          attendance.statusText,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isPresent ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              
                              // Thông tin chi tiết
                              if (attendance.date != null)
                                _buildInfoRow(Icons.calendar_today, 'Ngày:', attendance.date!),
                              if (attendance.timeRange.isNotEmpty)
                                _buildInfoRow(Icons.access_time, 'Giờ học:', attendance.timeRange),
                              if (attendance.classroom != null)
                                _buildInfoRow(Icons.location_on, 'Phòng:', attendance.classroom!),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatIndicator(bool isPresent, int count, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isPresent ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPresent ? Icons.check : Icons.close,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PRESENT':
        return Colors.green;
      case 'ABSENT':
        return Colors.red;
      case 'LATE':
        return Colors.orange;
      case 'EXCUSED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatMarkedAt(String markedAt) {
    try {
      // Parse từ "2024-10-07 07:15:00" hoặc ISO format
      DateTime dt;
      if (markedAt.contains('T')) {
        dt = DateTime.parse(markedAt);
      } else {
        dt = DateTime.parse(markedAt.replaceFirst(' ', 'T'));
      }
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return markedAt;
    }
  }
}
