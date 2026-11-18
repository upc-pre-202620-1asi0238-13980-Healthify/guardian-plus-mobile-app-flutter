sealed class LoginOutcome {
  const LoginOutcome();
}

final class SecondFactorRequired extends LoginOutcome {
  final String userAccountId;

  const SecondFactorRequired(this.userAccountId);
}

final class EmailVerificationRequired extends LoginOutcome {
  final String userAccountId;

  const EmailVerificationRequired(this.userAccountId);
}
