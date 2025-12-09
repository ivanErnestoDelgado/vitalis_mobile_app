class QRTokenResponse {
  final String token;
  final DateTime expiresAt;

  QRTokenResponse({required this.token, required this.expiresAt});

  factory QRTokenResponse.fromJson(Map<String, dynamic> json) {
    return QRTokenResponse(
      token: json["token"],
      expiresAt: DateTime.parse(json["expires_at"]).toLocal(),
    );
  }
}
