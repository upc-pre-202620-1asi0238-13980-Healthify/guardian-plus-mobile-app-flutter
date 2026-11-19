class UserProfileDto {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const UserProfileDto({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }
}

class CreateUserProfileRequestDto {
  final String userId;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const CreateUserProfileRequestDto({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'firstName': firstName,
    'lastName': lastName,
    'phoneNumber': phoneNumber,
  };
}

class UpdateUserProfileRequestDto {
  final String firstName;
  final String lastName;

  const UpdateUserProfileRequestDto({
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
  };
}

class UpdateContactInformationRequestDto {
  final String phoneNumber;

  const UpdateContactInformationRequestDto({required this.phoneNumber});

  Map<String, dynamic> toJson() => {'phoneNumber': phoneNumber};
}

class CareRecipientProfileDto {
  final String id;
  final String createdByUserId;
  final String firstName;
  final String lastName;
  final String birthDate;

  const CareRecipientProfileDto({
    required this.id,
    required this.createdByUserId,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
  });

  factory CareRecipientProfileDto.fromJson(Map<String, dynamic> json) {
    return CareRecipientProfileDto(
      id: json['id'] as String,
      createdByUserId: json['createdByUserId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      birthDate: json['birthDate'] as String,
    );
  }
}

class CreateCareRecipientProfileRequestDto {
  final String createdByUserId;
  final String firstName;
  final String lastName;
  final String birthDate;

  const CreateCareRecipientProfileRequestDto({
    required this.createdByUserId,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() => {
    'createdByUserId': createdByUserId,
    'firstName': firstName,
    'lastName': lastName,
    'birthDate': birthDate,
  };
}

class UpdateCareRecipientProfileRequestDto {
  final String firstName;
  final String lastName;
  final String birthDate;

  const UpdateCareRecipientProfileRequestDto({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'birthDate': birthDate,
  };
}

class CareRelationshipDto {
  final String id;
  final String userId;
  final String careRecipientProfileId;
  final String relationshipType;
  final String status;

  const CareRelationshipDto({
    required this.id,
    required this.userId,
    required this.careRecipientProfileId,
    required this.relationshipType,
    required this.status,
  });

  factory CareRelationshipDto.fromJson(Map<String, dynamic> json) {
    return CareRelationshipDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      careRecipientProfileId: json['careRecipientProfileId'] as String,
      relationshipType: json['relationshipType'] as String,
      status: json['status'] as String,
    );
  }
}

class EstablishCareRelationshipRequestDto {
  final String userId;
  final String careRecipientProfileId;
  final String relationshipType;

  const EstablishCareRelationshipRequestDto({
    required this.userId,
    required this.careRecipientProfileId,
    required this.relationshipType,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'careRecipientProfileId': careRecipientProfileId,
    'relationshipType': relationshipType,
  };
}

class UserPreferencesDto {
  final String userId;
  final String language;
  final bool notificationsEnabled;
  final bool highContrastEnabled;
  final bool reduceMotionEnabled;
  final String fontScale;
  final String updatedAt;

  const UserPreferencesDto({
    required this.userId,
    required this.language,
    required this.notificationsEnabled,
    required this.highContrastEnabled,
    required this.reduceMotionEnabled,
    required this.fontScale,
    required this.updatedAt,
  });

  factory UserPreferencesDto.fromJson(Map<String, dynamic> json) {
    return UserPreferencesDto(
      userId: json['userId'] as String,
      language: json['language'] as String,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      highContrastEnabled: json['highContrastEnabled'] as bool,
      reduceMotionEnabled: json['reduceMotionEnabled'] as bool,
      fontScale: json['fontScale'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class UpdateApplicationPreferencesRequestDto {
  final bool notificationsEnabled;

  const UpdateApplicationPreferencesRequestDto({
    required this.notificationsEnabled,
  });

  Map<String, dynamic> toJson() => {
    'notificationsEnabled': notificationsEnabled,
  };
}

class UpdateLanguageAccessibilityPreferencesRequestDto {
  final String language;
  final bool highContrastEnabled;
  final bool reduceMotionEnabled;
  final String fontScale;

  const UpdateLanguageAccessibilityPreferencesRequestDto({
    required this.language,
    required this.highContrastEnabled,
    required this.reduceMotionEnabled,
    required this.fontScale,
  });

  Map<String, dynamic> toJson() => {
    'language': language,
    'highContrastEnabled': highContrastEnabled,
    'reduceMotionEnabled': reduceMotionEnabled,
    'fontScale': fontScale,
  };
}
