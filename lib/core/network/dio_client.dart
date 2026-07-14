import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class DioClient {
  final Dio _dio;
  final SharedPreferences _sharedPreferences;
  
  // Stream to notify when token expires (401 Unauthorized)
  static final StreamController<void> _authExpiredController = StreamController<void>.broadcast();
  Stream<void> get authExpiredStream => _authExpiredController.stream;

  DioClient(this._sharedPreferences) : _dio = Dio() {
    _dio.options
      ..baseUrl = ApiConstants.baseUrl
      ..connectTimeout = const Duration(milliseconds: ApiConstants.connectTimeout)
      ..receiveTimeout = const Duration(milliseconds: ApiConstants.receiveTimeout)
      ..headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Fetch token from local storage
          final token = _sharedPreferences.getString('jwt_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // Token expiry handling (401 Unauthorized)
          if (e.response?.statusCode == 401) {
            // Check that we aren't trying to log in (which returns 401 for wrong credentials)
            final isLoginRequest = e.requestOptions.path.contains(ApiConstants.login);
            if (!isLoginRequest) {
              // Clear cached token
              await _sharedPreferences.remove('jwt_token');
              await _sharedPreferences.remove('user_data');
              
              // Broadcast token expired event
              _authExpiredController.add(null);
              return handler.reject(
                DioException(
                  requestOptions: e.requestOptions,
                  error: TokenExpiredException(),
                  type: DioExceptionType.unknown,
                ),
              );
            }
          }

          // Retry logic (only for connection issues or timeouts)
          final isNetworkError = e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              (e.type == DioExceptionType.unknown && e.error is SocketException);

          if (isNetworkError) {
            int retries = e.requestOptions.extra['retries'] ?? 0;
            if (retries < 3) {
              retries++;
              e.requestOptions.extra['retries'] = retries;
              
              // Exponential backoff
              final delay = Duration(milliseconds: retries * 1500);
              await Future.delayed(delay);
              
              try {
                final response = await _dio.fetch(e.requestOptions);
                return handler.resolve(response);
              } catch (_) {
                // If retry fails, continue to error mapper
              }
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  // HTTP GET Wrapper
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // HTTP POST Wrapper
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Map Dio Exceptions to custom Domain Exceptions
  Exception _handleDioError(DioException error) {
    if (error.error is TokenExpiredException) {
      return TokenExpiredException();
    }
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(message: 'Connection timed out. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String errorMessage = 'Something went wrong on the server.';
        
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        }
        
        return ServerException(message: errorMessage, statusCode: statusCode);
      case DioExceptionType.cancel:
        return ServerException(message: 'Request was cancelled.');
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException(message: 'No internet connection. Please connect and try again.');
        }
        return ServerException(message: 'An unexpected error occurred: ${error.message}');
      default:
        return ServerException(message: 'A network error occurred.');
    }
  }
}
