const authCodeLength = 6;
const resendCooldownSeconds = 30;

class OtpVerificationState {
  final String code;
  final bool isLoading;
  final String? errorMessage;
  final int resendAvailableInSec;
  final bool isResending;
  final String? actionMessage;

  const OtpVerificationState({
    this.code = '',
    this.isLoading = false,
    this.errorMessage,
    this.resendAvailableInSec = resendCooldownSeconds,
    this.isResending = false,
    this.actionMessage,
  });

  bool get isComplete => code.length == authCodeLength;

  bool get canResend => resendAvailableInSec == 0 && !isResending;

  String get resendCountdown {
    final minutes = resendAvailableInSec ~/ 60;

    final seconds = resendAvailableInSec % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static const _unset = Object();

  OtpVerificationState copyWith({
    String? code,
    bool? isLoading,
    Object? errorMessage = _unset,
    int? resendAvailableInSec,
    bool? isResending,
    Object? actionMessage = _unset,
  }) {
    return OtpVerificationState(
      code: code ?? this.code,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      resendAvailableInSec: resendAvailableInSec ?? this.resendAvailableInSec,
      isResending: isResending ?? this.isResending,
      actionMessage: identical(actionMessage, _unset)
          ? this.actionMessage
          : actionMessage as String?,
    );
  }
}
