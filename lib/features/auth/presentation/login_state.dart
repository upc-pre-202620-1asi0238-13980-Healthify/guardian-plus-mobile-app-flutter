class LoginState {
  final bool isPasswordHidden;
  final bool isLoading;
  final String? errorMessage;

  const LoginState({
    this.isPasswordHidden = true,
    this.isLoading = false,
    this.errorMessage,
  });

  static const _unset = Object();

  LoginState copyWith({
    bool? isPasswordHidden,
    bool? isLoading,
    Object? errorMessage = _unset,
  }) {
    return LoginState(
      isPasswordHidden: isPasswordHidden ?? this.isPasswordHidden,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
