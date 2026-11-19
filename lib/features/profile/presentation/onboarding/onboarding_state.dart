import 'package:guardian_plus_app/features/profile/domain/care_relationship.dart';

class OnboardingState {
  final bool showUserProfile;
  final bool showCareRecipient;

  final String firstName;
  final String lastName;
  final String phoneNumber;

  final String careRecipientFirstName;
  final String careRecipientLastName;
  final DateTime? careRecipientBirthDate;
  final RelationshipType relationshipType;

  final bool isLoading;
  final String? errorMessage;

  const OnboardingState({
    this.showUserProfile = false,
    this.showCareRecipient = false,
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.careRecipientFirstName = '',
    this.careRecipientLastName = '',
    this.careRecipientBirthDate,
    this.relationshipType = RelationshipType.family,
    this.isLoading = false,
    this.errorMessage,
  });

  static const _unset = Object();

  OnboardingState copyWith({
    bool? showUserProfile,
    bool? showCareRecipient,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? careRecipientFirstName,
    String? careRecipientLastName,
    Object? careRecipientBirthDate = _unset,
    RelationshipType? relationshipType,
    bool? isLoading,
    Object? errorMessage = _unset,
  }) {
    return OnboardingState(
      showUserProfile: showUserProfile ?? this.showUserProfile,
      showCareRecipient: showCareRecipient ?? this.showCareRecipient,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      careRecipientFirstName:
          careRecipientFirstName ?? this.careRecipientFirstName,
      careRecipientLastName:
          careRecipientLastName ?? this.careRecipientLastName,
      careRecipientBirthDate: identical(careRecipientBirthDate, _unset)
          ? this.careRecipientBirthDate
          : careRecipientBirthDate as DateTime?,
      relationshipType: relationshipType ?? this.relationshipType,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
