import 'package:guardian_plus_app/features/auth/domain/authenticated_session.dart';
import 'package:guardian_plus_app/features/auth/domain/login_outcome.dart';

abstract interface class AuthRepository {
  Future<LoginOutcome> login({required String email, required String password});

  Future<void> verifyEmail({
    required String userAccountId,
    required String code,
  });

  Future<void> resendEmailVerification(String userAccountId);

  Future<AuthenticatedSession> verifyOtp({
    required String userAccountId,
    required String code,
  });

  Future<void> resendOtp(String userAccountId);
}
