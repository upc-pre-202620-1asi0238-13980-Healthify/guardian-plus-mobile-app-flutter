import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/auth/application/resend_email_verification_use_case.dart';
import 'package:guardian_plus_app/features/auth/application/resend_otp_use_case.dart';
import 'package:guardian_plus_app/features/auth/application/verify_email_use_case.dart';
import 'package:guardian_plus_app/features/auth/application/verify_otp_use_case.dart';
import 'package:guardian_plus_app/features/auth/domain/otp_purpose.dart';
import 'package:guardian_plus_app/features/auth/presentation/otp/otp_verification_state.dart';

class OtpVerificationViewModel extends ChangeNotifier {
  final VerifyEmailUseCase verifyEmail;
  final VerifyOtpUseCase verifyOtp;
  final ResendEmailVerificationUseCase resendEmailVerification;
  final ResendOtpUseCase resendOtp;

  OtpVerificationViewModel({
    required this.verifyEmail,
    required this.verifyOtp,
    required this.resendEmailVerification,
    required this.resendOtp,
  }) {
    _startResendCountdown();
  }

  OtpVerificationState _state = const OtpVerificationState();

  OtpVerificationState get state => _state;

  Timer? _countdownTimer;

  void onCodeChanged(String value) {
    final code = value.length > authCodeLength
        ? value.substring(0, authCodeLength)
        : value;

    _state = _state.copyWith(code: code, errorMessage: null);

    notifyListeners();
  }

  Future<bool> verify({
    required String userAccountId,
    required OtpPurpose purpose,
  }) async {
    if (_state.isLoading || !_state.isComplete) {
      return false;
    }

    _state = _state.copyWith(isLoading: true, errorMessage: null);

    notifyListeners();

    try {
      switch (purpose) {
        case OtpPurpose.login:
          await verifyOtp.execute(
            userAccountId: userAccountId,
            code: _state.code,
          );

        case OtpPurpose.emailVerification:
          await verifyEmail.execute(
            userAccountId: userAccountId,
            code: _state.code,
          );
      }

      _state = _state.copyWith(isLoading: false, errorMessage: null);

      notifyListeners();

      return true;
    } catch (error) {
      _state = _state.copyWith(
        code: '',
        isLoading: false,
        errorMessage: error.toString(),
      );

      notifyListeners();

      return false;
    }
  }

  Future<void> resend({
    required String userAccountId,
    required OtpPurpose purpose,
  }) async {
    if (!_state.canResend) {
      return;
    }

    _state = _state.copyWith(isResending: true, actionMessage: null);

    notifyListeners();

    try {
      switch (purpose) {
        case OtpPurpose.login:
          await resendOtp.execute(userAccountId);

        case OtpPurpose.emailVerification:
          await resendEmailVerification.execute(userAccountId);
      }

      _state = _state.copyWith(
        code: '',
        isResending: false,
        errorMessage: null,
        actionMessage: 'Te enviamos un nuevo código.',
      );

      _startResendCountdown();
    } catch (error) {
      _state = _state.copyWith(
        isResending: false,
        actionMessage: error.toString(),
      );

      notifyListeners();
    }
  }

  void clearActionMessage() {
    _state = _state.copyWith(actionMessage: null);

    notifyListeners();
  }

  void _startResendCountdown() {
    _countdownTimer?.cancel();

    _state = _state.copyWith(resendAvailableInSec: resendCooldownSeconds);

    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = _state.resendAvailableInSec;

      if (remaining <= 1) {
        timer.cancel();

        _state = _state.copyWith(resendAvailableInSec: 0);
      } else {
        _state = _state.copyWith(resendAvailableInSec: remaining - 1);
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
