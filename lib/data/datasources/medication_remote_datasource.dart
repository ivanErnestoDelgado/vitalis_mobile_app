import 'package:dio/dio.dart';
import '../models/medication.dart';
import '../models/drug.dart';

class MedicationRemoteDataSource {
  final Dio _dio;
  late String token;

  MedicationRemoteDataSource({Dio? dio, required this.token})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: "http://192.168.100.61:8000/",
              headers: {
                "Content-Type": "application/json",
                'Authorization': 'Bearer $token',
              },
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ),
          ) {
    // Optional: logging
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<List<Medication>> fetchPatientMedications(int patientId) async {
    final res = await _dio.get("api/medications/patient/medications/");
    // backend returns all meds for authenticated patient; we still filter by patientId if needed
    final data = res.data as List<dynamic>;
    return data
        .map((e) => Medication.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Drug>> fetchDrugsWithVariants() async {
    final res = await _dio.get("api/medications/drugs/with-variants");
    final data = res.data as List<dynamic>;
    return data.map((e) => Drug.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Medication> createMedication(Map<String, dynamic> payload) async {
    final res = await _dio.post(
      "api/medications/patient/medications/",
      data: payload,
    );
    return Medication.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Medication> createMedicationForDoctor(
    Map<String, dynamic> payload,
  ) async {
    final res = await _dio.post(
      "api/medications/doctor/medications/",
      data: payload,
    );
    return Medication.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteMedication(int id) async {
    await _dio.delete("api/medications/patient/medications/$id/");
  }
}
