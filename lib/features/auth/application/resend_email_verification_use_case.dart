import 'package:guardian_plus_app/features/auth/domain/auth_repository.dart';

class ResendEmailVerificationUseCase {
  final AuthRepository repository;

  const ResendEmailVerificationUseCase({required this.repository});

  Future<void> execute(String userAccountId) {
    return repository.resendEmailVerification(userAccountId);
  }
}
