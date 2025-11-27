import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalis_mobile_app/providers/auth_provider.dart';
import '../data/datasources/shared_access_remote_datasource.dart';
import '../data/repositories/shared_access_repository.dart';
import '../data/models/shared_access.dart';
import '../data/models/qr_token_response.dart';
import 'dio_provider.dart';

final sharedAccessRepositoryProvider = Provider<SharedAccessRepository>((ref) {
  final dio = ref.read(dioProvider);
  final ds = SharedAccessRemoteDataSource(dio: dio);
  return SharedAccessRepository(ds);
});

final sharedAccessNotifierProvider =
    StateNotifierProvider<SharedAccessNotifier, AsyncValue<List<SharedAccess>>>(
      (ref) {
        final repo = ref.read(sharedAccessRepositoryProvider);
        return SharedAccessNotifier(repo, ref);
      },
    );

class SharedAccessNotifier
    extends StateNotifier<AsyncValue<List<SharedAccess>>> {
  final SharedAccessRepository repo;
  final Ref ref;

  SharedAccessNotifier(this.repo, this.ref)
    : super(const AsyncValue.loading()) {
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

  Future<SharedAccess> sendInvite(String email, String role) async {
    try {
      final res = await repo.sendInvite(email, role);
      await load();
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> accept(int id) async {
    try {
      await repo.accept(id);
      await load();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reject(int id) async {
    try {
      await repo.reject(id);
      await load();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> revoke(int id) async {
    try {
      await repo.revoke(id);
      await load();
    } catch (e) {
      rethrow;
    }
  }

  Future<QRTokenResponse> generateQR() async {
    try {
      return await repo.generateQR();
    } catch (e) {
      rethrow;
    }
  }

  Future<SharedAccess> connectViaQR(String token, String role) async {
    try {
      final r = await repo.connectQR(token, role);
      await load();
      return r;
    } catch (e) {
      rethrow;
    }
  }
}
