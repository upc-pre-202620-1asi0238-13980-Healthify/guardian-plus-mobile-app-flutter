import 'package:guardian_plus_app/features/profile/domain/care_recipient.dart';
import 'package:guardian_plus_app/features/profile/domain/care_relationship.dart';
import 'package:guardian_plus_app/features/profile/domain/user_preferences.dart';
import 'package:guardian_plus_app/features/profile/domain/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile?> findUserProfile(String userId);

  Future<UserProfile> createUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });

  Future<UserProfile> updateUserProfile({
    required String userProfileId,
    required String firstName,
    required String lastName,
  });

  Future<UserProfile> updateContactInformation({
    required String userProfileId,
    required String phoneNumber,
  });

  Future<List<CareRelationship>> getCareRelationships(String userId);

  Future<List<CareRelationship>> getCareRelationshipsByCareRecipient(
    String careRecipientProfileId,
  );

  Future<CareRecipient> getCareRecipient(String careRecipientProfileId);

  Future<CareRecipient> updateCareRecipient({
    required String careRecipientProfileId,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  });

  Future<CareRecipient> createCareRecipient({
    required String createdByUserId,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  });

  Future<CareRelationship> establishCareRelationship({
    required String userId,
    required String careRecipientProfileId,
    required RelationshipType relationshipType,
  });

  Future<UserPreferences?> findUserPreferences(String userId);

  Future<UserPreferences> updateApplicationPreferences({
    required String userId,
    required bool notificationsEnabled,
  });

  Future<UserPreferences> updateLanguageAndAccessibilityPreferences({
    required String userId,
    required AppLanguage language,
    required bool highContrastEnabled,
    required bool reduceMotionEnabled,
    required AppFontScale fontScale,
  });
}
