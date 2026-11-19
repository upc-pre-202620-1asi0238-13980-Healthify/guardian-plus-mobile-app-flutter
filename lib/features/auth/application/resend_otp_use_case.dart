import 'package:guardian_plus_app/features/auth/domain/auth_repository.dart';

class ResendOtpUseCase {
  final AuthRepository repository;

  const ResendOtpUseCase({required this.repository});

  Future<void> execute(String userAccountId) {
    return repository.resendOtp(userAccountId);
  }
}
