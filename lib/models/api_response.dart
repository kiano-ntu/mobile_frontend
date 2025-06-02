class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, {T? data}) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: data ?? json['data'],
      errors: json['errors'],
      statusCode: json['status_code'],
    );
  }

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      message: message ?? 'Success',
      data: data,
    );
  }

  factory ApiResponse.error(String message, {Map<String, dynamic>? errors, int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, data: $data}';
  }
}