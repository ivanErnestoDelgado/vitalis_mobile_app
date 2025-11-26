import 'package:dio/dio.dart';
import '../models/auth_response.dart';

class AuthRemoteDataSource {
  late final Dio _dio;

  AuthRemoteDataSource() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://127.0.0.1:8000/",
        headers: {"Content-Type": "application/json"},
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );

    // Logs para debugging (opcional)
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "api/users/login/",
        data: {"email": email, "password": password},
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Error: ${e.response?.data}");
      } else {
        throw Exception("No hay conexión con el servidor");
      }
    }
  }

  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      await _dio.post(
        "api/users/register/",
        data: {
          "email": email,
          "first_name": firstName,
          "last_name": lastName,
          "phone_number": phoneNumber,
          "password": password,
          "role": "patient", // IMPORTANTE: siempre patient como pediste
        },
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Error: ${e.response?.data}");
      } else {
        throw Exception("No hay conexión con el servidor");
      }
    }
  }
}
