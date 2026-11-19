import 'package:guardian_plus_app/features/profile/application/care_context_load.dart';
import 'package:guardian_plus_app/features/profile/application/load_care_context_use_case.dart';
import 'package:guardian_plus_app/features/profile/domain/care_relationship.dart';
import 'package:guardian_plus_app/features/profile/domain/profile_repository.dart';

class OnboardingData {
  final UserProfileData? userProfile;
  final CareRecipientData? careRecipient;

  const OnboardingData({this.userProfile, this.careRecipient});
}

class UserProfileData {
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const UserProfileData({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });
}

class CareRecipientData {
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final RelationshipType relationshipType;

  const CareRecipientData({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.relationshipType,
  });
}

class CompleteOnboardingUseCase {
  final ProfileRepository profileRepository;
  final LoadCareContextUseCase loadCareContext;

  const CompleteOnboardingUseCase({
    required this.profileRepository,
    required this.loadCareContext,
  });

  Future<CareContextLoad> execute({
    required String userAccountId,
    required OnboardingData data,
  }) async {
    final userProfile = data.userProfile;

    if (userProfile != null) {
      await profileRepository.createUserProfile(
        userId: userAccountId,
        firstName: userProfile.firstName,
        lastName: userProfile.lastName,
        phoneNumber: userProfile.phoneNumber,
      );
    }

    final careRecipientData = data.careRecipient;

    if (careRecipientData != null) {
      final careRecipient = await profileRepository.createCareRecipient(
        createdByUserId: userAccountId,
        firstName: careRecipientData.firstName,
        lastName: careRecipientData.lastName,
        birthDate: careRecipientData.birthDate,
      );

      await profileRepository.establishCareRelationship(
        userId: userAccountId,
        careRecipientProfileId: careRecipient.id,
        relationshipType: careRecipientData.relationshipType,
      );
    }

    return loadCareContext.execute();
  }
}
