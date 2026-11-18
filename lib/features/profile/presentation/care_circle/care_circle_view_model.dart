import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/profile/domain/care_relationship.dart';
import 'package:guardian_plus_app/features/profile/domain/profile_repository.dart';

class CareCircleMember {
  final String relationshipId;
  final String userId;
  final String displayName;
  final RelationshipType relationshipType;
  final bool active;

  const CareCircleMember({
    required this.relationshipId,
    required this.userId,
    required this.displayName,
    required this.relationshipType,
    required this.active,
  });

  String get relationshipLabel {
    switch (relationshipType) {
      case RelationshipType.family:
        return 'Familiar';

      case RelationshipType.caregiver:
        return 'Cuidador';
    }
  }
}

class CareCircleViewModel extends ChangeNotifier {
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  final ProfileRepository repository;
  final String careRecipientProfileId;

  CareCircleViewModel({
    required this.repository,
    required this.careRecipientProfileId,
  });

  List<CareCircleMember> _members = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CareCircleMember> get members => _members;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final relationships = await repository
          .getCareRelationshipsByCareRecipient(careRecipientProfileId);

      final activeRelationships = relationships
          .where((relationship) => relationship.active)
          .toList();

      final members = await Future.wait(
        activeRelationships.map((relationship) async {
          final profile = await repository.findUserProfile(relationship.userId);

          return CareCircleMember(
            relationshipId: relationship.id,
            userId: relationship.userId,
            displayName: profile?.fullName ?? 'Usuario',
            relationshipType: relationship.relationshipType,
            active: relationship.active,
          );
        }),
      );

      _members = members;
    } catch (_) {
      _errorMessage = 'No se pudo cargar el círculo de cuidado.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
