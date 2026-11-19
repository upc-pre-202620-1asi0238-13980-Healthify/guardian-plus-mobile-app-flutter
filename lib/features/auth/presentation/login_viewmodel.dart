import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/auth/application/login_use_case.dart';
import 'package:guardian_plus_app/features/auth/domain/login_outcome.dart';
import 'package:guardian_plus_app/features/auth/domain/otp_purpose.dart';
import 'package:guardian_plus_app/features/auth/presentation/login_state.dart';

class LoginNavigation {
  final String userAccountId;
  final String email;
  final OtpPurpose purpose;

  const LoginNavigation({
    required this.userAccountId,
    required this.email,
    required this.purpose,
  });
}

class LoginViewmodel extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  LoginViewmodel({required this.loginUseCase});

  LoginState _state = const LoginState();

  LoginState get state => _state;

  void togglePasswordVisibility() {
    _state = _state.copyWith(isPasswordHidden: !_state.isPasswordHidden);

    notifyListeners();
  }

  Future<LoginNavigation?> login({
    required String email,
    required String password,
  }) async {
    if (_state.isLoading) {
      return null;
    }

    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty || password.isEmpty) {
      _setError('Completa todos los campos para continuar');
      return null;
    }

    if (!_isValidEmail(normalizedEmail)) {
      _setError('Ingresa un correo electrónico válido');
      return null;
    }

    _state = _state.copyWith(isLoading: true, errorMessage: null);

    notifyListeners();

    try {
      final outcome = await loginUseCase.execute(
        email: normalizedEmail,
        password: password,
      );

      _state = _state.copyWith(isLoading: false, errorMessage: null);

      notifyListeners();

      if (outcome is SecondFactorRequired) {
        return LoginNavigation(
          userAccountId: outcome.userAccountId,
          email: normalizedEmail,
          purpose: OtpPurpose.login,
        );
      }

      if (outcome is EmailVerificationRequired) {
        return LoginNavigation(
          userAccountId: outcome.userAccountId,
          email: normalizedEmail,
          purpose: OtpPurpose.emailVerification,
        );
      }

      return null;
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );

      notifyListeners();

      return null;
    }
  }

  void _setError(String message) {
    _state = _state.copyWith(errorMessage: message);

    notifyListeners();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }
}
