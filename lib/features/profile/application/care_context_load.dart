import 'package:guardian_plus_app/core/session/care_context.dart';

sealed class CareContextLoad {
  const CareContextLoad();
}

final class CareContextReady extends CareContextLoad {
  final CareContext careContext;

  const CareContextReady(this.careContext);
}

final class CareContextOnboardingRequired extends CareContextLoad {
  final String userAccountId;
  final bool needsUserProfile;
  final bool needsCareRecipient;
  final String? suggestedFullName;

  const CareContextOnboardingRequired({
    required this.userAccountId,
    required this.needsUserProfile,
    required this.needsCareRecipient,
    this.suggestedFullName,
  });
}
