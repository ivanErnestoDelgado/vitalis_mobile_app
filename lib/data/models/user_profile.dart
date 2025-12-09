class UserProfile {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json["id"],
      email: json["email"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      phoneNumber: json["phone_number"],
      createdAt: DateTime.parse(json["created_at"]).toLocal(),
    );
  }
}
