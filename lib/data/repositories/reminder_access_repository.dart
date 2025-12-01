// lib/data/repositories/reminder_access_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/reminder_access_remote_datasource.dart';
import '../models/reminder_access.dart';

class ReminderAccessRepository {
  final ReminderAccessRemoteDataSource remote;

  ReminderAccessRepository(this.remote);

  Future<List<ReminderAccess>> getList() => remote.getAccessList();

  Future<ReminderAccess> create({
    required int reminderId,
    required int userId,
  }) => remote.createAccess(reminderId: reminderId, userId: userId);

  Future<void> delete(int id) => remote.deleteAccess(id);
}

final reminderAccessRepositoryProvider = Provider<ReminderAccessRepository>((
  ref,
) {
  final remote = ref.watch(reminderAccessRemoteDataSourceProvider);
  return ReminderAccessRepository(remote);
});
