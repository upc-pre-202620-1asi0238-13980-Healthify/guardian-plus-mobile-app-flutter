import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/profile/domain/profile_repository.dart';
import 'package:guardian_plus_app/features/profile/domain/user_preferences.dart';

class AccessibilityViewModel extends ChangeNotifier {
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

  AccessibilityViewModel({required this.repository, required this.userId});

  UserPreferences? _preferences;

  AppLanguage _language = AppLanguage.spanishLatinAmerica;

  bool _highContrastEnabled = false;
  bool _reduceMotionEnabled = false;

  AppFontScale _fontScale = AppFontScale.defaultScale;

  bool _isLoading = false;
  bool _isSaving = false;

  String? _errorMessage;
  String? _successMessage;

  bool get highContrastEnabled => _highContrastEnabled;

  bool get reduceMotionEnabled => _reduceMotionEnabled;

  AppFontScale get fontScale => _fontScale;

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

      final preferences = _preferences;

      if (preferences != null) {
        _language = preferences.language;
        _highContrastEnabled = preferences.highContrastEnabled;
        _reduceMotionEnabled = preferences.reduceMotionEnabled;
        _fontScale = preferences.fontScale;
      }
    } catch (_) {
      _errorMessage =
          'No se pudieron cargar tus preferencias de accesibilidad.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setHighContrast(bool enabled) {
    _highContrastEnabled = enabled;
    _successMessage = null;
    _errorMessage = null;
    notifyListeners();
  }

  void setReduceMotion(bool enabled) {
    _reduceMotionEnabled = enabled;
    _successMessage = null;
    _errorMessage = null;
    notifyListeners();
  }

  void setFontScale(AppFontScale value) {
    _fontScale = value;
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
      _preferences = await repository.updateLanguageAndAccessibilityPreferences(
        userId: userId,
        language: _language,
        highContrastEnabled: _highContrastEnabled,
        reduceMotionEnabled: _reduceMotionEnabled,
        fontScale: _fontScale,
      );

      _successMessage =
          'Las preferencias de accesibilidad se actualizaron correctamente.';

      return true;
    } catch (_) {
      _errorMessage = 'No se pudieron guardar las preferencias.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  String fontScaleLabel(AppFontScale value) {
    switch (value) {
      case AppFontScale.small:
        return 'Pequeño';

      case AppFontScale.defaultScale:
        return 'Predeterminado';

      case AppFontScale.large:
        return 'Grande';
    }
  }
}
