import 'package:guardian_plus_app/features/auth/domain/auth_repository.dart';
import 'package:guardian_plus_app/features/auth/domain/login_outcome.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase({required this.repository});

  Future<LoginOutcome> execute({
    required String email,
    required String password,
  }) async {
    final outcome = await repository.login(email: email, password: password);

    if (outcome is EmailVerificationRequired) {
      try {
        await repository.resendEmailVerification(outcome.userAccountId);
      } catch (_) {
        // The verification screen can request another
        // code manually if this automatic resend fails.
      }
    }

    return outcome;
  }
}
