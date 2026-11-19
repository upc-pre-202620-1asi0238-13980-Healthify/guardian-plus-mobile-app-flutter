import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/domain/profile_repository.dart';
import 'package:guardian_plus_app/features/profile/domain/user_preferences.dart';

class ProfilePreferencesController extends ChangeNotifier {
  final ProfileRepository repository;

  ProfilePreferencesController({required this.repository});

  UserPreferences? _preferences;

  UserPreferences? get preferences => _preferences;

  AppLanguage get language =>
      _preferences?.language ?? AppLanguage.spanishLatinAmerica;

  AppFontScale get fontScale =>
      _preferences?.fontScale ?? AppFontScale.defaultScale;

  bool get highContrastEnabled => _preferences?.highContrastEnabled ?? false;

  bool get reduceMotionEnabled => _preferences?.reduceMotionEnabled ?? false;

  double get textScale {
    switch (fontScale) {
      case AppFontScale.small:
        return 0.90;
      case AppFontScale.defaultScale:
        return 1.0;
      case AppFontScale.large:
        return 1.20;
    }
  }

  Future<void> load(String userId) async {
    try {
      _preferences = await repository.findUserPreferences(userId);
    } catch (_) {
      _preferences = null;
    }

    notifyListeners();
  }

  void apply(UserPreferences preferences) {
    _preferences = preferences;
    notifyListeners();
  }

  void clear() {
    _preferences = null;
    notifyListeners();
  }
}
