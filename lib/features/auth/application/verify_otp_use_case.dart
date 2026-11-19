import 'package:guardian_plus_app/features/auth/domain/auth_repository.dart';
import 'package:guardian_plus_app/features/auth/domain/authenticated_session.dart';
import 'package:guardian_plus_app/features/auth/domain/session_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;
  final SessionRepository sessionRepository;

  const VerifyOtpUseCase({
    required this.repository,
    required this.sessionRepository,
  });

  Future<AuthenticatedSession> execute({
    required String userAccountId,
    required String code,
  }) async {
    final session = await repository.verifyOtp(
      userAccountId: userAccountId,
      code: code,
    );

    sessionRepository.save(session);

    return session;
  }
}
