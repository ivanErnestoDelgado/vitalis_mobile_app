import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response.dart';

class AuthRepository {
  final AuthRemoteDataSource dataSource;

  AuthRepository(this.dataSource);

  Future<AuthResponse> login(String email, String password) {
    return dataSource.login(email, password);
  }

  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  }) {
    return dataSource.register(
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      password: password,
    );
  }
}
