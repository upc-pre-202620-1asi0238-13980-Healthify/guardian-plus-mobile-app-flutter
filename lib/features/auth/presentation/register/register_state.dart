class RegisterState {
  final bool isPasswordHidden;
  final bool isConfirmPasswordHidden;
  final bool isLoading;
  final String? errorMessage;

  const RegisterState({
    this.isPasswordHidden = true,
    this.isConfirmPasswordHidden = true,
    this.isLoading = false,
    this.errorMessage,
  });

  static const _unset = Object();

  RegisterState copyWith({
    bool? isPasswordHidden,
    bool? isConfirmPasswordHidden,
    bool? isLoading,
    Object? errorMessage = _unset,
  }) {
    return RegisterState(
      isPasswordHidden: isPasswordHidden ?? this.isPasswordHidden,
      isConfirmPasswordHidden:
          isConfirmPasswordHidden ?? this.isConfirmPasswordHidden,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
