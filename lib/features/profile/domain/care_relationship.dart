enum RelationshipType { family, caregiver }

class CareRelationship {
  final String id;
  final String userId;
  final String careRecipientProfileId;
  final RelationshipType relationshipType;
  final bool active;

  const CareRelationship({
    required this.id,
    required this.userId,
    required this.careRecipientProfileId,
    required this.relationshipType,
    required this.active,
  });
}
