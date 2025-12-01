// lib/providers/reminder_access_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/reminder_access.dart';
import '../data/repositories/reminder_access_repository.dart';

class ReminderAccessNotifier
    extends StateNotifier<AsyncValue<List<ReminderAccess>>> {
  final ReminderAccessRepository repo;

  ReminderAccessNotifier(this.repo) : super(const AsyncLoading()) {
    load();
  }

  Future<void> load() async {
    try {
      final items = await repo.getList();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> create({required int reminderId, required int userId}) async {
    try {
      final created = await repo.create(reminderId: reminderId, userId: userId);

      state = state.whenData((list) => [...list, created]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(int id) async {
    try {
      await repo.delete(id);
      state = state.whenData((list) => list.where((x) => x.id != id).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final reminderAccessNotifierProvider =
    StateNotifierProvider<
      ReminderAccessNotifier,
      AsyncValue<List<ReminderAccess>>
    >((ref) {
      final repo = ref.watch(reminderAccessRepositoryProvider);
      return ReminderAccessNotifier(repo);
    });
