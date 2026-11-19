import 'package:guardian_plus_app/core/session/care_context.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/auth/domain/session_repository.dart';
import 'package:guardian_plus_app/features/profile/application/care_context_load.dart';
import 'package:guardian_plus_app/features/profile/domain/profile_repository.dart';

class LoadCareContextUseCase {
  final SessionRepository sessionRepository;
  final ProfileRepository profileRepository;
  final CareContextStore careContextStore;

  const LoadCareContextUseCase({
    required this.sessionRepository,
    required this.profileRepository,
    required this.careContextStore,
  });

  Future<CareContextLoad> execute() async {
    final session = sessionRepository.currentSession();

    if (session == null) {
      throw StateError('No hay una sesión autenticada activa.');
    }

    final userAccountId = session.userAccountId;

    final userProfile = await profileRepository.findUserProfile(userAccountId);

    final relationships = await profileRepository.getCareRelationships(
      userAccountId,
    );

    final activeRelationships = relationships
        .where((relationship) => relationship.active)
        .toList();

    final relationship = activeRelationships.isEmpty
        ? null
        : activeRelationships.first;

    final careRecipient = relationship == null
        ? null
        : await profileRepository.getCareRecipient(
            relationship.careRecipientProfileId,
          );

    if (userProfile == null || careRecipient == null) {
      return CareContextOnboardingRequired(
        userAccountId: userAccountId,
        needsUserProfile: userProfile == null,
        needsCareRecipient: careRecipient == null,
      );
    }

    final careContext = CareContext(
      userAccountId: userAccountId,
      userFullName: userProfile.fullName,
      careRecipientProfileId: careRecipient.id,
      careRecipientName: careRecipient.fullName,
      callNumber: null,
    );

    careContextStore.save(careContext);

    return CareContextReady(careContext);
  }
}
