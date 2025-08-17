import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../models/homework_models.dart';

class ApiService {
  static const String baseUrl = 'http://172.16.3.136:8000'; // Change this to your backend URL
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
    ));

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
    ));
  }

  /// Upload homework file (image or PDF)
  Future<UploadResponse> uploadHomework(File file) async {
    try {
      String fileName = file.path.split('/').last;
      String? mimeType = _getMimeType(fileName);
      
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      });

      final response = await _dio.post(
        '/upload-homework',
        data: formData,
      );

      if (response.statusCode == 200) {
        return UploadResponse.fromJson(response.data);
      } else {
        throw ApiException('Upload failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Upload failed: $e');
    }
  }

  /// Solve homework problem by ID
  Future<Solution> solveHomework(String problemId) async {
    try {
      final response = await _dio.post('/homework/solve/$problemId');
      
      if (response.statusCode == 200) {
        return Solution.fromJson(response.data);
      } else {
        throw ApiException('Solve failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Solve failed: $e');
    }
  }

  /// Get homework problem details
  Future<HomeworkProblem> getHomeworkProblem(String problemId) async {
    try {
      final response = await _dio.get('/homework/$problemId');
      
      if (response.statusCode == 200) {
        return HomeworkProblem.fromJson(response.data);
      } else {
        throw ApiException('Get problem failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Get problem failed: $e');
    }
  }

  /// List recent homework problems
  Future<List<HomeworkProblem>> listHomeworkProblems({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/homework',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => HomeworkProblem.fromJson(json)).toList();
      } else {
        throw ApiException('List problems failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('List problems failed: $e');
    }
  }

  /// Delete homework problem
  Future<void> deleteHomeworkProblem(String problemId) async {
    try {
      final response = await _dio.delete('/homework/$problemId');
      
      if (response.statusCode != 200) {
        throw ApiException('Delete failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Delete failed: $e');
    }
  }

  /// Get AI providers information
  Future<Map<String, dynamic>> getAiProviders() async {
    try {
      final response = await _dio.get('/ai-providers');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ApiException('Get providers failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Get providers failed: $e');
    }
  }

  /// Get current AI provider
  Future<Map<String, dynamic>> getCurrentProvider() async {
    try {
      final response = await _dio.get('/ai-providers/current');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ApiException('Get current provider failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Get current provider failed: $e');
    }
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  String? _getMimeType(String fileName) {
    String extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return null;
    }
  }

  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException('Connection timeout. Please check your internet connection.');
      case DioExceptionType.sendTimeout:
        return ApiException('Send timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return ApiException('Receive timeout. The server took too long to respond.');
      case DioExceptionType.badResponse:
        String message = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data != null) {
          try {
            if (e.response!.data is Map && e.response!.data['detail'] != null) {
              message = e.response!.data['detail'].toString();
            } else if (e.response!.data is String) {
              message = e.response!.data;
            }
          } catch (_) {}
        }
        return ApiException(message);
      case DioExceptionType.cancel:
        return ApiException('Request cancelled.');
      case DioExceptionType.connectionError:
        return ApiException('Connection error. Please check your internet connection.');
      default:
        return ApiException('Network error: ${e.message}');
    }
  }
}

class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => message;
}
