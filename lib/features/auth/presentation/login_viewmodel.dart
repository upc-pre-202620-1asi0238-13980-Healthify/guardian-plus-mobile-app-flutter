import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/auth/presentation/login_state.dart';

class LoginViewmodel  extends ChangeNotifier {
    LoginState _state=  LoginState();

    LoginState get state => _state;

    void togglePasswordVisibility() {
        _state = _state.copyWith(isPasswordHidden: !_state.isPasswordHidden);
        notifyListeners();
    }
}
