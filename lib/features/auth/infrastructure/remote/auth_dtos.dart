class RegisteredUserAccountDto {
  final String id;
  final String email;

  const RegisteredUserAccountDto({required this.id, required this.email});

  factory RegisteredUserAccountDto.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['userAccountId'];

    final rawEmail = json['email'];

    if (rawId is! String || rawId.trim().isEmpty) {
      throw const FormatException(
        'La cuenta registrada no tiene identificador.',
      );
    }

    if (rawEmail is! String || rawEmail.trim().isEmpty) {
      throw const FormatException('La cuenta registrada no tiene correo.');
    }

    return RegisteredUserAccountDto(id: rawId, email: rawEmail);
  }
}

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
    this.tokenType,
    required this.expiresAt,
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
