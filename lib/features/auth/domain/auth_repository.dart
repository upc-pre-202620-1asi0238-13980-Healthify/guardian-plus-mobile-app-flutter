import 'package:guardian_plus_app/features/auth/domain/authenticated_session.dart';
import 'package:guardian_plus_app/features/auth/domain/login_outcome.dart';
import 'package:guardian_plus_app/features/auth/domain/registered_user_account.dart';

abstract interface class AuthRepository {
  Future<RegisteredUserAccount> register({
    required String fullName,
    required String email,
    required String password,
  });

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
