import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' as foundation;

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8080';
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<dynamic> getJson(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    foundation.debugPrint('GET: $uri');
    foundation.debugPrint('Headers: $jsonHeaders');
    
    // Retry logic
    for (int i = 0; i < 3; i++) {
      try {
        foundation.debugPrint('Attempt ${i + 1}/3 - GET: $uri');
        foundation.debugPrint('Headers: $jsonHeaders');
        
        final res = await http.get(uri, headers: jsonHeaders).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            foundation.debugPrint('Timeout after 30 seconds');
            throw Exception('Request timeout after 30 seconds');
          },
        );
        
        foundation.debugPrint('Response status: ${res.statusCode}');
        foundation.debugPrint('Response headers: ${res.headers}');
        foundation.debugPrint('Response body length: ${res.body.length}');
        
        _checkResponse(res);
        return json.decode(res.body);
      } catch (e) {
        foundation.debugPrint('Error in getJson attempt ${i + 1}: $e');
        foundation.debugPrint('Error type: ${e.runtimeType}');
        if (i == 2) rethrow; // Throw on last attempt
        foundation.debugPrint('Waiting 2 seconds before retry...');
        await Future.delayed(const Duration(seconds: 2)); // Wait before retry
      }
    }
    throw Exception('All retry attempts failed');
  }

  Future<dynamic> postJson(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    foundation.debugPrint('POST: $uri, Body: ${json.encode(body)}');
    final res = await http.post(uri, headers: jsonHeaders, body: json.encode(body)).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout after 30 seconds');
      },
    );
    _checkResponse(res);
    return json.decode(res.body);
  }

  Future<dynamic> putJson(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    foundation.debugPrint('PUT: $uri, Body: ${json.encode(body)}');
    final res = await http.put(uri, headers: jsonHeaders, body: json.encode(body)).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('Request timeout after 30 seconds');
      },
    );
    _checkResponse(res);
    return json.decode(res.body);
  }

  void _checkResponse(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(status: res.statusCode, message: res.body);
    }
  }
}

class ApiException implements Exception {
  final int status;
  final String message;
  ApiException({required this.status, required this.message});
  @override
  String toString() => 'ApiException(status: $status, message: $message)';
}













