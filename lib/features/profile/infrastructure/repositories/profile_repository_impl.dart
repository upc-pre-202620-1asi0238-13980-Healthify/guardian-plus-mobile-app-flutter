import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/features/profile/domain/care_recipient.dart';
import 'package:guardian_plus_app/features/profile/domain/care_relationship.dart';
import 'package:guardian_plus_app/features/profile/domain/profile_repository.dart';
import 'package:guardian_plus_app/features/profile/domain/user_preferences.dart';
import 'package:guardian_plus_app/features/profile/domain/user_profile.dart';
import 'package:guardian_plus_app/features/profile/infrastructure/mappers/profile_mappers.dart';
import 'package:guardian_plus_app/features/profile/infrastructure/remote/profile_api.dart';
import 'package:guardian_plus_app/features/profile/infrastructure/remote/profile_dtos.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApi api;

  const ProfileRepositoryImpl({required this.api});

  @override
  Future<UserProfile?> findUserProfile(String userId) async {
    try {
      final dto = await api.getUserProfileByUserId(userId);

      return dto.toDomain();
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return null;
      }

      rethrow;
    }
  }

  @override
  Future<UserProfile> createUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    final dto = await api.createUserProfile(
      CreateUserProfileRequestDto(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      ),
    );

    return dto.toDomain();
  }

  @override
  Future<UserProfile> updateUserProfile({
    required String userProfileId,
    required String firstName,
    required String lastName,
  }) async {
    final dto = await api.updateUserProfile(
      userProfileId: userProfileId,
      request: UpdateUserProfileRequestDto(
        firstName: firstName,
        lastName: lastName,
      ),
    );

    return dto.toDomain();
  }

  @override
  Future<UserProfile> updateContactInformation({
    required String userProfileId,
    required String phoneNumber,
  }) async {
    final dto = await api.updateContactInformation(
      userProfileId: userProfileId,
      request: UpdateContactInformationRequestDto(phoneNumber: phoneNumber),
    );

    return dto.toDomain();
  }

  @override
  Future<List<CareRelationship>> getCareRelationships(String userId) async {
    final dtos = await api.getCareRelationshipsByUserId(userId);

    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<List<CareRelationship>> getCareRelationshipsByCareRecipient(
    String careRecipientProfileId,
  ) async {
    final dtos = await api.getCareRelationshipsByCareRecipient(
      careRecipientProfileId,
    );

    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<CareRecipient> getCareRecipient(String careRecipientProfileId) async {
    final dto = await api.getCareRecipientProfile(careRecipientProfileId);

    return dto.toDomain();
  }

  @override
  Future<CareRecipient> updateCareRecipient({
    required String careRecipientProfileId,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  }) async {
    final dto = await api.updateCareRecipientProfile(
      careRecipientProfileId: careRecipientProfileId,
      request: UpdateCareRecipientProfileRequestDto(
        firstName: firstName,
        lastName: lastName,
        birthDate: _dateOnly(birthDate),
      ),
    );

    return dto.toDomain();
  }

  @override
  Future<CareRecipient> createCareRecipient({
    required String createdByUserId,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  }) async {
    final dto = await api.createCareRecipientProfile(
      CreateCareRecipientProfileRequestDto(
        createdByUserId: createdByUserId,
        firstName: firstName,
        lastName: lastName,
        birthDate: _dateOnly(birthDate),
      ),
    );

    return dto.toDomain();
  }

  @override
  Future<CareRelationship> establishCareRelationship({
    required String userId,
    required String careRecipientProfileId,
    required RelationshipType relationshipType,
  }) async {
    final dto = await api.establishCareRelationship(
      EstablishCareRelationshipRequestDto(
        userId: userId,
        careRecipientProfileId: careRecipientProfileId,
        relationshipType: relationshipTypeToApi(relationshipType),
      ),
    );

    return dto.toDomain();
  }

  @override
  Future<UserPreferences?> findUserPreferences(String userId) async {
    try {
      final dto = await api.getUserPreferences(userId);

      return dto.toDomain();
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return null;
      }

      rethrow;
    }
  }

  @override
  Future<UserPreferences> updateApplicationPreferences({
    required String userId,
    required bool notificationsEnabled,
  }) async {
    final dto = await api.updateApplicationPreferences(
      userId: userId,
      request: UpdateApplicationPreferencesRequestDto(
        notificationsEnabled: notificationsEnabled,
      ),
    );

    return dto.toDomain();
  }

  @override
  Future<UserPreferences> updateLanguageAndAccessibilityPreferences({
    required String userId,
    required AppLanguage language,
    required bool highContrastEnabled,
    required bool reduceMotionEnabled,
    required AppFontScale fontScale,
  }) async {
    final dto = await api.updateLanguageAccessibilityPreferences(
      userId: userId,
      request: UpdateLanguageAccessibilityPreferencesRequestDto(
        language: appLanguageToApi(language),
        highContrastEnabled: highContrastEnabled,
        reduceMotionEnabled: reduceMotionEnabled,
        fontScale: appFontScaleToApi(fontScale),
      ),
    );

    return dto.toDomain();
  }

  String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
