import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/auth/application/register_use_case.dart';
import 'package:guardian_plus_app/features/auth/presentation/register/register_state.dart';

class RegisterNavigation {
  final String userAccountId;
  final String email;

  const RegisterNavigation({required this.userAccountId, required this.email});
}

class RegisterViewmodel extends ChangeNotifier {
  final RegisterUseCase registerUseCase;

  RegisterViewmodel({required this.registerUseCase});

  RegisterState _state = const RegisterState();

  RegisterState get state => _state;

  void togglePasswordVisibility() {
    _state = _state.copyWith(isPasswordHidden: !_state.isPasswordHidden);

    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _state = _state.copyWith(
      isConfirmPasswordHidden: !_state.isConfirmPasswordHidden,
    );

    notifyListeners();
  }

  Future<RegisterNavigation?> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (_state.isLoading) {
      return null;
    }

    final normalizedName = fullName.trim();

    final normalizedEmail = email.trim();

    if (normalizedName.isEmpty ||
        normalizedEmail.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _setError('Completa todos los campos para continuar');

      return null;
    }

    if (!_isValidEmail(normalizedEmail)) {
      _setError('Ingresa un correo electrónico válido');

      return null;
    }

    if (password.length < 8) {
      _setError('La contraseña debe tener al menos 8 caracteres');

      return null;
    }

    if (password != confirmPassword) {
      _setError('Las contraseñas no coinciden');

      return null;
    }

    _state = _state.copyWith(isLoading: true, errorMessage: null);

    notifyListeners();

    try {
      final account = await registerUseCase.execute(
        fullName: normalizedName,
        email: normalizedEmail,
        password: password,
      );

      _state = _state.copyWith(isLoading: false, errorMessage: null);

      notifyListeners();

      return RegisterNavigation(
        userAccountId: account.id,
        email: account.email,
      );
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
