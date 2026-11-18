import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/features/auth/domain/auth_repository.dart';
import 'package:guardian_plus_app/features/auth/domain/authenticated_session.dart';
import 'package:guardian_plus_app/features/auth/domain/login_outcome.dart';
import 'package:guardian_plus_app/features/auth/infrastructure/remote/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi api;

  const AuthRepositoryImpl({required this.api});

  @override
  Future<LoginOutcome> login({
    required String email,
    required String password,
  }) async {
    try {
      final challenge = await api.login(email: email, password: password);

      return SecondFactorRequired(challenge.userAccountId);
    } on ApiException catch (error) {
      if (error.code == 'EMAIL_NOT_VERIFIED' &&
          error.details != null &&
          error.details!.isNotEmpty) {
        return EmailVerificationRequired(error.details!);
      }

      rethrow;
    }
  }

  @override
  Future<AuthenticatedSession> verifyOtp({
    required String userAccountId,
    required String code,
  }) async {
    final dto = await api.verifyOtp(userAccountId: userAccountId, code: code);

    return AuthenticatedSession(
      userAccountId: dto.userAccountId,
      accessToken: dto.accessToken,
      expiresAt: DateTime.parse(dto.expiresAt).toUtc(),
    );
  }

  @override
  Future<void> resendOtp(String userAccountId) {
    return api.resendOtp(userAccountId);
  }
}
