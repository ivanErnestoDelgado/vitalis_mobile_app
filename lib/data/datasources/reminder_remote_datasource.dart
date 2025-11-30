import 'package:dio/dio.dart';
import '../models/reminder.dart';

class ReminderRemoteDataSource {
  final Dio dio;

  ReminderRemoteDataSource({required this.dio});

  Future<List<Reminder>> getMyReminders() async {
    try {
      final res = await dio.get('/reminders/patient/reminders/');
      final List data = res.data as List;
      return data.map((e) => Reminder.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<Reminder> createReminder(Map<String, dynamic> body) async {
    try {
      final res = await dio.post('/reminders/patient/reminders/', data: body);
      return Reminder.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<void> deleteReminder(int id) async {
    try {
      await dio.delete('/reminders/patient/reminders/$id/');
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<Reminder> getReminderById(int id) async {
    final response = await dio.get('/reminders/patient/reminders/$id/');

    return Reminder.fromJson(response.data);
  }

  Future<Reminder> updateReminder({
    required int reminderId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await dio.put(
        '/reminders/patient/reminders/$reminderId/',
        data: body,
      );

      return Reminder.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
