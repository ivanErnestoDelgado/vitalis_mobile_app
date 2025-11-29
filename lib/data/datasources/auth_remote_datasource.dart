import 'package:dio/dio.dart';
import '../models/auth_response.dart';
import '../../utils/fcm_service.dart';

class AuthRemoteDataSource {
  late final Dio _dio;

  AuthRemoteDataSource() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.100.61:8000/",
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

  //función para iniciar sesión y manejar token FCM
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "api/users/login/",
        data: {"email": email, "password": password},
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // obtener token FCM
      final fcmToken = await FCMService.getToken();

      if (fcmToken != null) {
        await sendFcmToken(fcmToken, authResponse.accessToken);
      }

      return authResponse;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception("Error: ${e.response?.data}");
      } else {
        throw Exception("No hay conexión con el servidor");
      }
    }
  }

  //función para enviar el token FCM al backend
  Future<void> sendFcmToken(String fcmToken, String authToken) async {
    try {
      await _dio.post(
        "api/users/register-fcm-token/",
        data: {"fcm_token": fcmToken},
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );
    } on DioException catch (e) {
      print("Error al registrar FCM token: ${e.response?.data}");
    }
  }

  //función para registrar un nuevo usuario
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
          "role": "patient",
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
