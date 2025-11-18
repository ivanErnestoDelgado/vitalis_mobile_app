class AuthResponse {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final List<String> roles;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.roles,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      roles: List<String>.from(json['roles']),
      accessToken: json['tokens']['access'],
      refreshToken: json['tokens']['refresh'],
    );
  }
}
