import 'package:dio/dio.dart';
import '../../data/models/shared_access.dart';
import '../../data/models/qr_token_response.dart';

class SharedAccessRemoteDataSource {
  final Dio dio;

  SharedAccessRemoteDataSource({required this.dio});

  Future<SharedAccess> sendInvitation({
    required String email,
    required String role,
  }) async {
    try {
      final res = await dio.post(
        '/shared/shared-access/invite/',
        data: {'email': email, 'role': role},
      );
      return SharedAccess.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<List<SharedAccess>> getMySharedAccesses() async {
    try {
      final res = await dio.get('/shared/shared-access/');
      final data = res.data as List<dynamic>;
      return data
          .map((e) => SharedAccess.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<SharedAccess> acceptInvitation(int id) async {
    try {
      final res = await dio.post('/shared/shared-access/$id/accept/');
      return SharedAccess.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<void> rejectInvitation(int id) async {
    try {
      await dio.post('/shared/shared-access/$id/reject/');
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<void> revokeInvitation(int id) async {
    try {
      await dio.delete('/shared/shared-access/$id/revoke/');
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<QRTokenResponse> generateQRToken() async {
    try {
      final res = await dio.post('/shared/shared-access/generate_qr_token/');
      return QRTokenResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<SharedAccess> connectViaQR({
    required String token,
    required String role,
  }) async {
    try {
      final res = await dio.post(
        '/shared/shared-access/connect_via_qr/',
        data: {'token': token, 'role': role},
      );
      return SharedAccess.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }
}
