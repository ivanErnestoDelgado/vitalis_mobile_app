// lib/data/datasource/reminder_access_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_access.dart';
import '../../providers/dio_provider.dart';

class ReminderAccessRemoteDataSource {
  final Dio dio;
  ReminderAccessRemoteDataSource(this.dio);

  // Crear
  Future<ReminderAccess> createAccess({
    required int reminderId,
    required int userId,
  }) async {
    final response = await dio.post(
      "/reminders/reminder-access/",
      data: {"reminder": reminderId, "user": userId},
    );
    return ReminderAccess.fromJson(response.data);
  }

  // Listar
  Future<List<ReminderAccess>> getAccessList() async {
    final response = await dio.get("/reminders/reminder-access/");
    return (response.data as List)
        .map((e) => ReminderAccess.fromJson(e))
        .toList();
  }

  // Eliminar
  Future<void> deleteAccess(int id) async {
    await dio.delete("/reminders/reminder-access/$id/");
  }
}

final reminderAccessRemoteDataSourceProvider =
    Provider<ReminderAccessRemoteDataSource>((ref) {
      final dio = ref.watch(dioProvider);
      return ReminderAccessRemoteDataSource(dio);
    });
