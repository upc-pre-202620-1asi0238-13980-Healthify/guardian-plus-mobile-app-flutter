import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/subscriptions/domain/subscription.dart';
import 'package:guardian_plus_app/features/subscriptions/domain/subscription_repository.dart';

class MyPlanViewModel extends ChangeNotifier {
  final SubscriptionRepository repository;
  final String subscriberId;

  MyPlanViewModel({required this.repository, required this.subscriberId});

  SubscriptionSummary? _summary;

  bool _isLoading = false;
  bool _isCancelling = false;

  bool _loadFailed = false;
  bool _cancellationFailed = false;
  bool _cancellationSucceeded = false;

  SubscriptionSummary? get summary => _summary;

  bool get isLoading => _isLoading;
  bool get isCancelling => _isCancelling;

  bool get loadFailed => _loadFailed;
  bool get cancellationFailed => _cancellationFailed;
  bool get cancellationSucceeded => _cancellationSucceeded;

  Future<void> load() async {
    _isLoading = true;
    _loadFailed = false;

    notifyListeners();

    try {
      _summary = await repository.getCurrentSubscription(subscriberId);
    } catch (_) {
      _loadFailed = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelAtPeriodEnd() async {
    final current = _summary;

    if (current == null ||
        !current.subscription.canRequestCancellation ||
        _isCancelling) {
      return false;
    }

    _isCancelling = true;
    _cancellationFailed = false;
    _cancellationSucceeded = false;

    notifyListeners();

    try {
      final updated = await repository.requestCancellation(
        current.subscription.id,
      );

      _summary = current.copyWith(subscription: updated);

      _cancellationSucceeded = true;

      return true;
    } catch (_) {
      _cancellationFailed = true;

      return false;
    } finally {
      _isCancelling = false;
      notifyListeners();
    }
  }
}
