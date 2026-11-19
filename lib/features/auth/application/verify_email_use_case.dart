import 'package:guardian_plus_app/features/auth/domain/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository repository;

  const VerifyEmailUseCase({required this.repository});

  Future<void> execute({required String userAccountId, required String code}) {
    return repository.verifyEmail(userAccountId: userAccountId, code: code);
  }
}
