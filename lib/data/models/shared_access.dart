import 'user_profile.dart';

class SharedAccess {
  final int id;
  final UserProfile owner;
  final UserProfile sharedWith;
  final String role;
  final String status;
  final DateTime createdAt;

  SharedAccess({
    required this.id,
    required this.owner,
    required this.sharedWith,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  factory SharedAccess.fromJson(Map<String, dynamic> json) {
    return SharedAccess(
      id: json["id"],
      owner: UserProfile.fromJson(json["owner"]),
      sharedWith: UserProfile.fromJson(json["shared_with"]),
      role: json["role"],
      status: json["status"],
      createdAt: DateTime.parse(json["created_at"]).toLocal(),
    );
  }
}
