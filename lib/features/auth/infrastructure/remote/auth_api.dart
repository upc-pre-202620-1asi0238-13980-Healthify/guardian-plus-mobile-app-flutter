import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/auth/infrastructure/remote/auth_dtos.dart';

class AuthApi {
  final ApiClient apiClient;

  const AuthApi({required this.apiClient});

  Future<OtpChallengeDto> login({
    required String email,
    required String password,
  }) async {
    final json = await apiClient.post(
      'auth/login',
      authenticated: false,
      body: {'email': email, 'password': password},
    );

    return OtpChallengeDto.fromJson(Map<String, dynamic>.from(json as Map));
  }

  Future<AuthenticatedSessionDto> verifyOtp({
    required String userAccountId,
    required String code,
  }) async {
    final json = await apiClient.post(
      'auth/otp/verify',
      authenticated: false,
      body: {'userAccountId': userAccountId, 'code': code},
    );

    return AuthenticatedSessionDto.fromJson(
      Map<String, dynamic>.from(json as Map),
    );
  }

  Future<void> resendOtp(String userAccountId) async {
    await apiClient.post(
      'auth/otp/resend',
      authenticated: false,
      body: {'userAccountId': userAccountId},
    );
  }
}
