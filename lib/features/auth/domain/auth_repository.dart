import 'package:guardian_plus_app/features/auth/domain/authenticated_session.dart';
import 'package:guardian_plus_app/features/auth/domain/login_outcome.dart';

abstract interface class AuthRepository {
  Future<LoginOutcome> login({required String email, required String password});

  Future<AuthenticatedSession> verifyOtp({
    required String userAccountId,
    required String code,
  });

  Future<void> resendOtp(String userAccountId);
}
