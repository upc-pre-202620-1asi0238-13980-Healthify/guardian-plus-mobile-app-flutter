import 'package:guardian_plus_app/features/profile/domain/care_recipient.dart';
import 'package:guardian_plus_app/features/profile/domain/care_relationship.dart';
import 'package:guardian_plus_app/features/profile/domain/user_preferences.dart';
import 'package:guardian_plus_app/features/profile/domain/user_profile.dart';
import 'package:guardian_plus_app/features/profile/infrastructure/remote/profile_dtos.dart';

extension UserProfileDtoMapper on UserProfileDto {
  UserProfile toDomain() {
    return UserProfile(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );
  }
}

extension CareRecipientProfileDtoMapper on CareRecipientProfileDto {
  CareRecipient toDomain() {
    return CareRecipient(
      id: id,
      firstName: firstName,
      lastName: lastName,
      birthDate: DateTime.parse(birthDate),
    );
  }
}

extension CareRelationshipDtoMapper on CareRelationshipDto {
  CareRelationship toDomain() {
    return CareRelationship(
      id: id,
      userId: userId,
      careRecipientProfileId: careRecipientProfileId,
      relationshipType: _relationshipTypeFromApi(relationshipType),
      active: status == 'ACTIVE',
    );
  }
}

extension UserPreferencesDtoMapper on UserPreferencesDto {
  UserPreferences toDomain() {
    return UserPreferences(
      userId: userId,
      language: _languageFromApi(language),
      notificationsEnabled: notificationsEnabled,
      highContrastEnabled: highContrastEnabled,
      reduceMotionEnabled: reduceMotionEnabled,
      fontScale: _fontScaleFromApi(fontScale),
    );
  }
}

RelationshipType _relationshipTypeFromApi(String value) {
  switch (value) {
    case 'FAMILY':
      return RelationshipType.family;

    case 'CAREGIVER':
      return RelationshipType.caregiver;

    default:
      throw FormatException('RelationshipType desconocido: $value');
  }
}

AppLanguage _languageFromApi(String value) {
  switch (value) {
    case 'SPANISH_LATIN_AMERICA':
      return AppLanguage.spanishLatinAmerica;

    case 'ENGLISH_UNITED_STATES':
      return AppLanguage.englishUnitedStates;

    default:
      throw FormatException('AppLanguage desconocido: $value');
  }
}

AppFontScale _fontScaleFromApi(String value) {
  switch (value) {
    case 'SMALL':
      return AppFontScale.small;

    case 'DEFAULT':
      return AppFontScale.defaultScale;

    case 'LARGE':
      return AppFontScale.large;

    default:
      throw FormatException('AppFontScale desconocido: $value');
  }
}

String relationshipTypeToApi(RelationshipType value) {
  switch (value) {
    case RelationshipType.family:
      return 'FAMILY';

    case RelationshipType.caregiver:
      return 'CAREGIVER';
  }
}

String appLanguageToApi(AppLanguage value) {
  switch (value) {
    case AppLanguage.spanishLatinAmerica:
      return 'SPANISH_LATIN_AMERICA';

    case AppLanguage.englishUnitedStates:
      return 'ENGLISH_UNITED_STATES';
  }
}

String appFontScaleToApi(AppFontScale value) {
  switch (value) {
    case AppFontScale.small:
      return 'SMALL';

    case AppFontScale.defaultScale:
      return 'DEFAULT';

    case AppFontScale.large:
      return 'LARGE';
  }
}
