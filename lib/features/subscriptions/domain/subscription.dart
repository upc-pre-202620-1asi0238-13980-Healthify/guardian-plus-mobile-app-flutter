class Subscription {
  final String id;
  final String subscriberId;
  final String planId;
  final String status;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.subscriberId,
    required this.planId,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get canRequestCancellation =>
      status.toUpperCase() == 'ACTIVE' && !cancelAtPeriodEnd;
}

class Entitlement {
  final String code;
  final String name;
  final String description;

  const Entitlement({
    required this.code,
    required this.name,
    required this.description,
  });
}

class SubscriptionSummary {
  final Subscription subscription;
  final List<Entitlement> entitlements;

  const SubscriptionSummary({
    required this.subscription,
    required this.entitlements,
  });

  SubscriptionSummary copyWith({
    Subscription? subscription,
    List<Entitlement>? entitlements,
  }) {
    return SubscriptionSummary(
      subscription: subscription ?? this.subscription,
      entitlements: entitlements ?? this.entitlements,
    );
  }
}
