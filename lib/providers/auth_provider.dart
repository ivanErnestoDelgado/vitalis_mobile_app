import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/auth_response.dart';
import '../data/repositories/auth_repository.dart';
import '../data/datasources/auth_remote_datasource.dart';

/// Inyección del repositorio
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(AuthRemoteDataSource()),
);

/// Controlador de estado
final authStateProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthResponse?>>(
      (ref) => AuthController(ref),
    );

class AuthController extends StateNotifier<AsyncValue<AuthResponse?>> {
  final Ref ref;

  AuthController(this.ref) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final resp = await ref
          .read(authRepositoryProvider)
          .login(email, password);
      state = AsyncValue.data(resp);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void logout() {
    state = const AsyncValue.data(null);
  }
}
