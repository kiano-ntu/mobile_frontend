import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../services/storage_service.dart';

class ApiService {
  static final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ============= HEADERS WITH TOKEN =============
  static Future<Map<String, String>> _getAuthHeaders() async {
    final headers = Map<String, String>.from(_defaultHeaders);
    final token = await StorageService.getToken();
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // ============= ERROR HANDLING =============
  static String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    } else if (error is HttpException) {
      return 'Terjadi kesalahan pada server.';
    } else if (error is FormatException) {
      return 'Format data tidak valid.';
    } else {
      return error.toString();
    }
  }

  // ============= POST REQUEST =============
  static Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final headers = requiresAuth ? await _getAuthHeaders() : _defaultHeaders;
      
      print('🚀 POST Request: $endpoint');
      print('📤 Data: $data');
      print('🔑 Headers: $headers');

      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(timeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.fromJson(responseData, data: responseData['data']);
      } else {
        return ApiResponse<T>.error(
          responseData['message'] ?? 'Terjadi kesalahan',
          errors: responseData['errors'],
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ API Error: $e');
      return ApiResponse<T>.error(_handleError(e));
    }
  }

  // ============= GET REQUEST =============
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    bool requiresAuth = false,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final headers = requiresAuth ? await _getAuthHeaders() : _defaultHeaders;
      
      print('🚀 GET Request: $endpoint');
      print('🔑 Headers: $headers');

      final response = await http
          .get(
            Uri.parse(endpoint),
            headers: headers,
          )
          .timeout(timeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.fromJson(responseData, data: responseData['data']);
      } else {
        return ApiResponse<T>.error(
          responseData['message'] ?? 'Terjadi kesalahan',
          errors: responseData['errors'],
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ API Error: $e');
      return ApiResponse<T>.error(_handleError(e));
    }
  }

  // ============= PUT REQUEST =============
  static Future<ApiResponse<T>> put<T>(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final headers = requiresAuth ? await _getAuthHeaders() : _defaultHeaders;

      print('🚀 PUT Request: $endpoint');
      print('📤 Data: $data');

      final response = await http
          .put(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(timeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.fromJson(responseData, data: responseData['data']);
      } else {
        return ApiResponse<T>.error(
          responseData['message'] ?? 'Terjadi kesalahan',
          errors: responseData['errors'],
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ API Error: $e');
      return ApiResponse<T>.error(_handleError(e));
    }
  }

  // ============= DELETE REQUEST =============
  static Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool requiresAuth = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final headers = requiresAuth ? await _getAuthHeaders() : _defaultHeaders;

      print('🚀 DELETE Request: $endpoint');

      final response = await http
          .delete(
            Uri.parse(endpoint),
            headers: headers,
          )
          .timeout(timeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.fromJson(responseData, data: responseData['data']);
      } else {
        return ApiResponse<T>.error(
          responseData['message'] ?? 'Terjadi kesalahan',
          errors: responseData['errors'],
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ API Error: $e');
      return ApiResponse<T>.error(_handleError(e));
    }
  }

  // ============= UTILITY METHODS =============
  
  /// Check if response is successful
  static bool isSuccessResponse(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }
  
  /// Get timeout duration based on request type
  static Duration getTimeoutDuration(String requestType) {
    switch (requestType.toLowerCase()) {
      case 'upload':
        return const Duration(minutes: 5);
      case 'download':
        return const Duration(minutes: 10);
      default:
        return const Duration(seconds: 30);
    }
  }
}