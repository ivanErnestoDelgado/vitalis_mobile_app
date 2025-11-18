import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response.dart';

class AuthRepository {
  final AuthRemoteDataSource dataSource;

  AuthRepository(this.dataSource);

  Future<AuthResponse> login(String email, String password) {
    return dataSource.login(email, password);
  }
}
