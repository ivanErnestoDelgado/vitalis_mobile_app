import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/auth_repository.dart';
import '../data/datasources/auth_remote_datasource.dart';

final registerControllerProvider =
    StateNotifierProvider<RegisterController, AsyncValue<void>>(
      (ref) => RegisterController(ref),
    );

class RegisterController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  late final AuthRepository _data;

  RegisterController(this.ref) : super(const AsyncValue.data(null)) {
    _data = AuthRepository(AuthRemoteDataSource());
  }

  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _data.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phone,
        password: password,
      );

      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
