import '../datasources/shared_access_remote_datasource.dart';
import '../models/shared_access.dart';
import '../models/qr_token_response.dart';

class SharedAccessRepository {
  final SharedAccessRemoteDataSource remote;

  SharedAccessRepository(this.remote);

  Future<SharedAccess> sendInvite(String email, String role) =>
      remote.sendInvitation(email: email, role: role);

  Future<List<SharedAccess>> getAll() => remote.getMySharedAccesses();

  Future<SharedAccess> accept(int id) => remote.acceptInvitation(id);

  Future<void> reject(int id) => remote.rejectInvitation(id);

  Future<void> revoke(int id) => remote.revokeInvitation(id);

  Future<QRTokenResponse> generateQR() => remote.generateQRToken();

  Future<SharedAccess> connectQR(String token, String role) =>
      remote.connectViaQR(token: token, role: role);
}
