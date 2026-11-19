class AuthenticatedSession {
  final String userAccountId;
  final String accessToken;
  final DateTime expiresAt;

  const AuthenticatedSession({
    required this.userAccountId,
    required this.accessToken,
    required this.expiresAt,
  });

  bool isExpired([DateTime? now]) {
    final current = now ?? DateTime.now().toUtc();
    return !current.isBefore(expiresAt.toUtc());
  }
}
