import '../datasources/reminder_remote_datasource.dart';
import '../models/reminder.dart';

class ReminderRepository {
  final ReminderRemoteDataSource ds;

  ReminderRepository(this.ds);

  Future<List<Reminder>> getAll() => ds.getMyReminders();

  Future<Reminder> create(Map<String, dynamic> body) => ds.createReminder(body);

  Future<void> delete(int id) => ds.deleteReminder(id);

  Future<Reminder> getReminderById(int id) {
    return ds.getReminderById(id);
  }

  Future<Reminder> updateReminder({
    required int reminderId,
    required Map<String, dynamic> body,
  }) async {
    return await ds.updateReminder(reminderId: reminderId, body: body);
  }
}
