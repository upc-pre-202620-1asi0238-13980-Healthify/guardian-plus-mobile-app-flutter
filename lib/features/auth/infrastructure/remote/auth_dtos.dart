class OtpChallengeDto {
  final String userAccountId;
  final String? message;

  const OtpChallengeDto({required this.userAccountId, this.message});

  factory OtpChallengeDto.fromJson(Map<String, dynamic> json) {
    return OtpChallengeDto(
      userAccountId: json['userAccountId'] as String,
      message: json['message'] as String?,
    );
  }
}

class AuthenticatedSessionDto {
  final String userAccountId;
  final String accessToken;
  final String? tokenType;
  final String expiresAt;

  const AuthenticatedSessionDto({
    required this.userAccountId,
    required this.accessToken,
    required this.expiresAt,
    this.tokenType,
  });

  factory AuthenticatedSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthenticatedSessionDto(
      userAccountId: json['userAccountId'] as String,
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String?,
      expiresAt: json['expiresAt'] as String,
    );
  }
}
