enum AppLanguage { spanishLatinAmerica, englishUnitedStates }

enum AppFontScale { small, defaultScale, large }

class UserPreferences {
  final String userId;
  final AppLanguage language;
  final bool notificationsEnabled;
  final bool highContrastEnabled;
  final bool reduceMotionEnabled;
  final AppFontScale fontScale;

  const UserPreferences({
    required this.userId,
    required this.language,
    required this.notificationsEnabled,
    required this.highContrastEnabled,
    required this.reduceMotionEnabled,
    required this.fontScale,
  });
}
