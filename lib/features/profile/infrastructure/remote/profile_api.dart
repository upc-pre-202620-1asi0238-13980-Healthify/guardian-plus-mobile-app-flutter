import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/profile/infrastructure/remote/profile_dtos.dart';

class ProfileApi {
  final ApiClient client;

  const ProfileApi({required this.client});

  Future<UserProfileDto> getUserProfileByUserId(String userId) async {
    final json = await client.get('user-profiles/user/$userId');

    return UserProfileDto.fromJson(json as Map<String, dynamic>);
  }

  Future<UserProfileDto> createUserProfile(
    CreateUserProfileRequestDto request,
  ) async {
    final json = await client.post('user-profiles', body: request.toJson());

    return UserProfileDto.fromJson(json as Map<String, dynamic>);
  }

  Future<UserProfileDto> updateUserProfile({
    required String userProfileId,
    required UpdateUserProfileRequestDto request,
  }) async {
    final json = await client.put(
      'user-profiles/$userProfileId',
      body: request.toJson(),
    );

    return UserProfileDto.fromJson(json as Map<String, dynamic>);
  }

  Future<UserProfileDto> updateContactInformation({
    required String userProfileId,
    required UpdateContactInformationRequestDto request,
  }) async {
    final json = await client.put(
      'user-profiles/$userProfileId/contact-information',
      body: request.toJson(),
    );

    return UserProfileDto.fromJson(json as Map<String, dynamic>);
  }

  Future<CareRecipientProfileDto> getCareRecipientProfile(
    String careRecipientProfileId,
  ) async {
    final json = await client.get(
      'care-recipient-profiles/$careRecipientProfileId',
    );

    return CareRecipientProfileDto.fromJson(json as Map<String, dynamic>);
  }

  Future<CareRecipientProfileDto> createCareRecipientProfile(
    CreateCareRecipientProfileRequestDto request,
  ) async {
    final json = await client.post(
      'care-recipient-profiles',
      body: request.toJson(),
    );

    return CareRecipientProfileDto.fromJson(json as Map<String, dynamic>);
  }

  Future<CareRecipientProfileDto> updateCareRecipientProfile({
    required String careRecipientProfileId,
    required UpdateCareRecipientProfileRequestDto request,
  }) async {
    final json = await client.put(
      'care-recipient-profiles/$careRecipientProfileId',
      body: request.toJson(),
    );

    return CareRecipientProfileDto.fromJson(json as Map<String, dynamic>);
  }

  Future<List<CareRelationshipDto>> getCareRelationshipsByUserId(
    String userId,
  ) async {
    final json = await client.get('care-relationships/user/$userId');

    return (json as List)
        .map(
          (item) => CareRelationshipDto.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<CareRelationshipDto>> getCareRelationshipsByCareRecipient(
    String careRecipientProfileId,
  ) async {
    final json = await client.get(
      'care-relationships/care-recipient/'
      '$careRecipientProfileId',
    );

    return (json as List)
        .map(
          (item) => CareRelationshipDto.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<CareRelationshipDto> establishCareRelationship(
    EstablishCareRelationshipRequestDto request,
  ) async {
    final json = await client.post(
      'care-relationships',
      body: request.toJson(),
    );

    return CareRelationshipDto.fromJson(json as Map<String, dynamic>);
  }

  Future<UserPreferencesDto> getUserPreferences(String userId) async {
    final json = await client.get('user-preferences/user/$userId');

    return UserPreferencesDto.fromJson(json as Map<String, dynamic>);
  }

  Future<UserPreferencesDto> updateApplicationPreferences({
    required String userId,
    required UpdateApplicationPreferencesRequestDto request,
  }) async {
    final json = await client.put(
      'user-preferences/user/$userId/application',
      body: request.toJson(),
    );

    return UserPreferencesDto.fromJson(json as Map<String, dynamic>);
  }

  Future<UserPreferencesDto> updateLanguageAccessibilityPreferences({
    required String userId,
    required UpdateLanguageAccessibilityPreferencesRequestDto request,
  }) async {
    final json = await client.put(
      'user-preferences/user/'
      '$userId/language-accessibility',
      body: request.toJson(),
    );

    return UserPreferencesDto.fromJson(json as Map<String, dynamic>);
  }
}
