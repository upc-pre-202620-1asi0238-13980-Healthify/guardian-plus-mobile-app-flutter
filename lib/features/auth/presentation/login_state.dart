class LoginState {
    const new({
        this.isPasswordHidden = true,
        this.isLoading = false,
        this.errorMessage,
    });


    final bool isPasswordHidden;
    final bool isLoading;
    final String? errorMessage;

    LoginState copyWith({
        bool? isPasswordHidden,
        bool? isLoading,
        String? errorMessage
    }) {
        return LoginState(
            isPasswordHidden: isPasswordHidden ?? this.isPasswordHidden,
            isLoading: isLoading ?? this.isLoading,
            errorMessage:  errorMessage ?? this.errorMessage
        );
    }
}
