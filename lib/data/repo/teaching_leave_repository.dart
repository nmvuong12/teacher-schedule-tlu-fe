import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_client.dart';
import '../model/teaching_leave_dto.dart';

class TeachingLeaveRepository {
  Future<void> create(TeachingLeaveDto dto) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/api/teaching-leaves');
    final res = await http.post(
      uri,
      headers: ApiClient.jsonHeaders,
      body: json.encode(dto.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      // Parse error message from response body
      String errorMessage = 'Không thể tạo yêu cầu nghỉ dạy';
      try {
        final errorBody = json.decode(res.body);
        if (errorBody is Map<String, dynamic>) {
          // Check for common error message patterns
          if (errorBody['message'] != null) {
            errorMessage = errorBody['message'] as String;
          } else if (errorBody['error'] != null) {
            errorMessage = errorBody['error'] as String;
          }
          // Check if error contains "already exists"
          final bodyString = res.body.toLowerCase();
          if (bodyString.contains('already exists') || 
              bodyString.contains('đã tồn tại')) {
            errorMessage = 'Buổi học này đã có yêu cầu nghỉ dạy. Vui lòng kiểm tra lại.';
          }
        }
      } catch (e) {
        // If parsing fails, use default message
        final bodyString = res.body.toLowerCase();
        if (bodyString.contains('already exists') || 
            bodyString.contains('đã tồn tại')) {
          errorMessage = 'Buổi học này đã có yêu cầu nghỉ dạy. Vui lòng kiểm tra lại.';
        }
      }
      throw Exception(errorMessage);
    }
  }

  Future<void> update(int sessionId, TeachingLeaveDto dto) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/api/teaching-leaves/$sessionId');
    final res = await http.put(
      uri,
      headers: ApiClient.jsonHeaders,
      body: json.encode(dto.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Update teaching leave failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<List<TeachingLeaveDto>> getAll() async {
    final uri = Uri.parse('${ApiClient.baseUrl}/api/teaching-leaves');
    final res = await http.get(uri, headers: ApiClient.jsonHeaders);
    if (res.statusCode != 200) {
      throw Exception('GET teaching leaves failed: ${res.statusCode} ${res.body}');
    }
    final List data = json.decode(res.body) as List;
    return data.map((e) => TeachingLeaveDto.fromJson(e)).toList();
  }

  // Kiểm tra xem đã có yêu cầu nghỉ dạy cho session này chưa
  Future<TeachingLeaveDto?> getBySessionId(int sessionId) async {
    try {
      final uri = Uri.parse('${ApiClient.baseUrl}/api/teaching-leaves/session/$sessionId');
      final res = await http.get(uri, headers: ApiClient.jsonHeaders);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data != null) {
          return TeachingLeaveDto.fromJson(data);
        }
      } else if (res.statusCode == 404) {
        // Không tìm thấy - chưa có yêu cầu nghỉ dạy
        return null;
      }
      return null;
    } catch (e) {
      // Nếu endpoint không tồn tại, thử lấy tất cả và filter
      try {
        final allLeaves = await getAll();
        final found = allLeaves.where((leave) => leave.sessionId == sessionId).firstOrNull;
        return found;
      } catch (e2) {
        return null;
      }
    }
  }
}


