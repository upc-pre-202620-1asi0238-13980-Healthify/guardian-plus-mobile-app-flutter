import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/profile/domain/profile_repository.dart';
import 'package:guardian_plus_app/features/profile/domain/user_preferences.dart';
import 'package:flutter/widgets.dart';

class ProfilePreferencesController extends ChangeNotifier {
  final ProfileRepository repository;

  ProfilePreferencesController({required this.repository});

  UserPreferences? _preferences;

  UserPreferences? get preferences => _preferences;

  AppLanguage get language =>
      _preferences?.language ?? AppLanguage.spanishLatinAmerica;

  bool get highContrastEnabled => _preferences?.highContrastEnabled ?? false;

  bool get reduceMotionEnabled => _preferences?.reduceMotionEnabled ?? false;

  AppFontScale get fontScale =>
      _preferences?.fontScale ?? AppFontScale.defaultScale;

  double get textScale {
    switch (fontScale) {
      case AppFontScale.small:
        return 0.90;

      case AppFontScale.defaultScale:
        return 1.0;

      case AppFontScale.large:
        return 1.15;
    }
  }

  Locale get locale {
    switch (language) {
      case AppLanguage.spanishLatinAmerica:
        return const Locale('es');

      case AppLanguage.englishUnitedStates:
        return const Locale('en');
    }
  }

  String get languageLabel {
    switch (language) {
      case AppLanguage.spanishLatinAmerica:
        return 'Español (Latinoamérica)';

      case AppLanguage.englishUnitedStates:
        return 'English (United States)';
    }
  }

  Future<void> loadForUser(String userId) async {
    final preferences = await repository.findUserPreferences(userId);

    if (preferences == null) {
      clear();
      return;
    }

    apply(preferences);
  }

  Future<void> load(String userId) => loadForUser(userId);

  void apply(UserPreferences preferences) {
    _preferences = preferences;
    notifyListeners();
  }

  void setPreferences(UserPreferences preferences) {
    apply(preferences);
  }

  void update(UserPreferences preferences) {
    apply(preferences);
  }

  void clear() {
    _preferences = null;
    notifyListeners();
  }
}
