import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/profile/domain/profile_repository.dart';
import 'package:guardian_plus_app/features/profile/domain/user_preferences.dart';

class LanguageViewModel extends ChangeNotifier {
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  final ProfileRepository repository;
  final String userId;

  LanguageViewModel({required this.repository, required this.userId});

  UserPreferences? _preferences;
  AppLanguage _selectedLanguage = AppLanguage.spanishLatinAmerica;

  bool _isLoading = false;
  bool _isSaving = false;

  String? _errorMessage;
  String? _successMessage;

  UserPreferences? get preferences => _preferences;
  AppLanguage get selectedLanguage => _selectedLanguage;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _preferences = await repository.findUserPreferences(userId);

      if (_preferences != null) {
        _selectedLanguage = _preferences!.language;
      }
    } catch (_) {
      _errorMessage = 'No se pudo cargar la preferencia de idioma.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectLanguage(AppLanguage language) {
    if (_selectedLanguage == language) {
      return;
    }

    _selectedLanguage = language;
    _successMessage = null;
    _errorMessage = null;

    notifyListeners();
  }

  Future<bool> save() async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final current = _preferences;

      _preferences = await repository.updateLanguageAndAccessibilityPreferences(
        userId: userId,
        language: _selectedLanguage,
        highContrastEnabled: current?.highContrastEnabled ?? false,
        reduceMotionEnabled: current?.reduceMotionEnabled ?? false,
        fontScale: current?.fontScale ?? AppFontScale.defaultScale,
      );

      _selectedLanguage = _preferences!.language;

      _successMessage = 'El idioma se actualizó correctamente.';

      return true;
    } catch (_) {
      _errorMessage = 'No se pudo actualizar el idioma.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  String labelFor(AppLanguage language) {
    switch (language) {
      case AppLanguage.spanishLatinAmerica:
        return 'Español (Latinoamérica)';

      case AppLanguage.englishUnitedStates:
        return 'English (United States)';
    }
  }
}
