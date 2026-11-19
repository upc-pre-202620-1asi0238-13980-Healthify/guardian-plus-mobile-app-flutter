import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/domain/profile_repository.dart';
import 'package:guardian_plus_app/features/profile/domain/user_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  final ProfileRepository repository;
  final String userId;

  SettingsViewModel({required this.repository, required this.userId});

  bool _isLoading = false;
  bool _isSaving = false;
  bool _needsInitialization = false;
  String? _errorMessage;
  UserPreferences? _preferences;

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  bool get needsInitialization => _needsInitialization;

  String? get errorMessage => _errorMessage;

  UserPreferences? get preferences => _preferences;

  Future<void> load() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _preferences = await repository.findUserPreferences(userId);

      _needsInitialization = _preferences == null;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar las preferencias.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> initializePreferences({
    required bool notificationsEnabled,
  }) async {
    if (_isSaving) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _preferences = await repository.updateApplicationPreferences(
        userId: userId,
        notificationsEnabled: notificationsEnabled,
      );

      _needsInitialization = false;

      return true;
    } catch (_) {
      _errorMessage = 'No se pudieron configurar las preferencias.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }
}
