import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/reminder.dart';
import '../data/datasources/reminder_remote_datasource.dart';
import '../data/repositories/reminder_repository.dart';
import '../providers/dio_provider.dart';
import 'auth_provider.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final dio = ref.read(dioProvider);
  final ds = ReminderRemoteDataSource(dio: dio);
  return ReminderRepository(ds);
});

final remindersNotifierProvider =
    StateNotifierProvider<RemindersNotifier, AsyncValue<List<Reminder>>>((ref) {
      final repo = ref.read(reminderRepositoryProvider);
      return RemindersNotifier(repo, ref);
    });

class RemindersNotifier extends StateNotifier<AsyncValue<List<Reminder>>> {
  final ReminderRepository repo;
  final Ref ref;

  RemindersNotifier(this.repo, this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    final auth = ref.read(authStateProvider).value;
    if (auth == null) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final data = await repo.getAll();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Reminder> createReminder({
    required String title,
    required String message,
    required DateTime startTime,
    required String frequency,
    int? intervalHours,
    required int medication,
  }) async {
    try {
      final body = {
        "title": title,
        "message": message,
        "start_time": startTime.toUtc().toIso8601String(),
        "frequency": frequency,
        "interval_hours": intervalHours,
        "medication": medication,
      };

      final r = await repo.create(body);
      await load();
      return r;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReminder(int id) async {
    try {
      await repo.delete(id);
      await load();
    } catch (e) {
      rethrow;
    }
  }

  Future<Reminder> updateReminder({
    required int id,
    required String title,
    required String message,
    required DateTime startTime,
    required String frequency,
    int? intervalHours,
    required int medication,
  }) async {
    try {
      final body = {
        "title": title,
        "message": message,
        "start_time": startTime.toUtc().toIso8601String(),
        "frequency": frequency,
        "interval_hours": intervalHours,
        "medication": medication,
      };

      final updated = await repo.updateReminder(reminderId: id, body: body);

      //recargar lista de reminders
      await load();

      return updated;
    } catch (e) {
      rethrow;
    }
  }
}

final reminderByIdProvider = FutureProvider.family<Reminder, int>((
  ref,
  id,
) async {
  final repo = ref.watch(reminderRepositoryProvider);
  return repo.getReminderById(id);
});
