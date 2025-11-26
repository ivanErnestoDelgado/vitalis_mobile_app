class SharedAccess {
  final int id;
  final int owner;
  final int sharedWith;
  final String role; // family | doctor
  final String status; // pending | accepted | rejected
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
      owner: json["owner"],
      sharedWith: json["shared_with"],
      role: json["role"],
      status: json["status"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}
