import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/subscriptions/domain/subscription.dart';
import 'package:guardian_plus_app/features/subscriptions/domain/subscription_repository.dart';
import 'package:guardian_plus_app/features/subscriptions/infrastructure/payments/stripe_payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PlanMessage {
  updated,
  paymentCancelled,
  awaitingConfirmation,
  failed,
  stripeNotConfigured,
  stateChanged,
  cancellationSucceeded,
}

class MyPlanViewModel extends ChangeNotifier {
  final SubscriptionRepository repository;
  final String subscriberId;
  final StripePaymentService paymentService;

  MyPlanViewModel({
    required this.repository,
    required this.subscriberId,
    StripePaymentService? paymentService,
  }) : paymentService = paymentService ?? StripePaymentService();

  SubscriptionSummary? _summary;
  List<SubscriptionPlan> _plans = const [];

  bool _isLoading = false;
  bool _isBusy = false;
  bool _loadFailed = false;
  bool _disposed = false;

  PlanMessage? _message;
  _PaymentConfirmation? _confirmation;

  String get _pendingRenewalKey =>
      'guardian_plus.subscriptions.pending_renewal.v1.$subscriberId';

  SubscriptionSummary? get summary => _summary;
  List<SubscriptionPlan> get plans => _plans;

  bool get isLoading => _isLoading;
  bool get isBusy => _isBusy;
  bool get loadFailed => _loadFailed;
  bool get awaitingConfirmation => _confirmation != null;

  PlanMessage? get message => _message;

  Subscription? get current => _summary?.subscription;

  SubscriptionPlan? get currentPlan {
    for (final plan in _plans) {
      if (plan.id == current?.planId) {
        return plan;
      }
    }
    return null;
  }

  bool get canMutate =>
      !_disposed &&
      !_isLoading &&
      !_isBusy &&
      !_loadFailed &&
      !awaitingConfirmation;

  bool canSelectPlan(SubscriptionPlan plan) {
    if (!canMutate || !plan.active) return false;

    final subscription = current;

    if (subscription == null) return true;

    if (subscription.isPending) {
      return subscription.planId == plan.id;
    }

    return subscription.isActive &&
        !subscription.isCancellationScheduled &&
        subscription.planId != plan.id &&
        plan.isFree;
  }

  bool get canRenew =>
      canMutate &&
      current?.canRequestRenewal == true &&
      currentPlan?.requiresPayment == true;

  bool get canCancel => canMutate && current?.canRequestCancellation == true;

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _readSummary() async {
    final result = await repository.getCurrentSubscription(subscriberId);

    if (!_disposed) {
      _summary = result;
    }
  }

  Future<void> _restoreRenewal() async {
    final preferences = await SharedPreferences.getInstance();

    final raw = preferences.getString(_pendingRenewalKey);

    if (raw == null) return;

    final json = jsonDecode(raw) as Map<String, dynamic>;

    final restored = _PaymentConfirmation.fromJson(json);

    if (restored.previousPeriodEnd == null) {
      throw const FormatException('Invalid pending renewal');
    }

    if (!_disposed) {
      _confirmation = restored;
    }
  }

  Future<void> _rememberConfirmation(_PaymentConfirmation confirmation) async {
    if (confirmation.previousPeriodEnd != null) {
      final preferences = await SharedPreferences.getInstance();

      final saved = await preferences.setString(
        _pendingRenewalKey,
        jsonEncode(confirmation.toJson()),
      );

      if (!saved) {
        throw StateError('Unable to persist pending renewal');
      }
    }

    _confirmation = confirmation;
  }

  Future<void> _clearConfirmation() async {
    if (_confirmation?.previousPeriodEnd != null) {
      final preferences = await SharedPreferences.getInstance();

      final removed = await preferences.remove(_pendingRenewalKey);

      if (!removed) {
        throw StateError('Unable to clear pending renewal');
      }
    }

    _confirmation = null;
  }

  Future<bool> _resolveConfirmation() async {
    if (_confirmation?.matches(_summary) != true) {
      return false;
    }

    await _clearConfirmation();

    _message = PlanMessage.updated;

    return true;
  }

  Future<void> load() async {
    if (_disposed || _isBusy || _isLoading) return;

    _isLoading = true;
    _loadFailed = false;
    _emit();

    try {
      if (_confirmation == null) {
        await _restoreRenewal();
      }

      final catalog = await repository.getPlans();

      await _readSummary();

      if (_disposed) return;

      _plans = List.unmodifiable(catalog);

      if (_confirmation != null) {
        if (!await _resolveConfirmation()) {
          _message = PlanMessage.awaitingConfirmation;
        }
      }
    } catch (_) {
      _loadFailed = true;
    } finally {
      _isLoading = false;
      _emit();
    }
  }

  bool _sameState(Subscription? before, Subscription? after) {
    if (before == null || after == null) {
      return before == null && after == null;
    }

    return before.id == after.id &&
        before.planId == after.planId &&
        before.status == after.status &&
        before.currentPeriodEnd == after.currentPeriodEnd &&
        before.cancelAtPeriodEnd == after.cancelAtPeriodEnd;
  }

  Future<bool> _run(Future<void> Function() operation) async {
    if (!canMutate) return false;

    _isBusy = true;
    _message = null;
    _emit();

    try {
      await operation();

      return true;
    } catch (_) {
      try {
        await _readSummary();

        if (await _resolveConfirmation()) {
          return true;
        }
      } catch (_) {
        _loadFailed = true;
      }

      _message = awaitingConfirmation
          ? PlanMessage.awaitingConfirmation
          : PlanMessage.failed;

      return false;
    } finally {
      _isBusy = false;
      _emit();
    }
  }

  Future<void> selectPlan(SubscriptionPlan plan) async {
    if (!canSelectPlan(plan)) return;

    if (plan.requiresPayment && !paymentService.isConfigured) {
      _message = PlanMessage.stripeNotConfigured;
      _emit();
      return;
    }

    final previous = current;

    await _run(() async {
      await _readSummary();

      if (_disposed) return;

      if (!_sameState(previous, current)) {
        _message = PlanMessage.stateChanged;
        return;
      }

      final existing = current;

      final Subscription subscription;

      if (existing == null || (existing.isPending && plan.isFree)) {
        subscription = await repository.requestSubscription(
          subscriberId: subscriberId,
          planId: plan.id,
        );
      } else if (existing.isPending) {
        subscription = existing;
      } else {
        if (!plan.isFree) {
          throw StateError('Paid plan changes are unavailable');
        }

        subscription = await repository.changePlan(
          subscriptionId: existing.id,
          newPlanId: plan.id,
        );
      }

      if (_disposed) return;

      await _readSummary();

      if (_disposed) return;

      if (subscription.planId != plan.id ||
          subscription.subscriberId != subscriberId) {
        throw StateError('Unexpected subscription');
      }

      if (plan.requiresPayment && subscription.isPending) {
        final payment = await repository.initiateActivationPayment(
          subscription.id,
        );

        await _handlePayment(payment, subscription: subscription, plan: plan);
      } else {
        if (current?.id != subscription.id ||
            current?.isActive != true ||
            current?.planId != plan.id) {
          throw StateError('Subscription not confirmed');
        }

        _message = PlanMessage.updated;
      }
    });
  }

  Future<void> renew() async {
    if (!canRenew) return;

    if (!paymentService.isConfigured) {
      _message = PlanMessage.stripeNotConfigured;
      _emit();
      return;
    }

    final previous = current!;
    final plan = currentPlan!;

    await _run(() async {
      await _readSummary();

      if (_disposed) return;

      if (!_sameState(previous, current)) {
        _message = PlanMessage.stateChanged;
        return;
      }

      final payment = await repository.initiateRenewalPayment(previous.id);

      await _handlePayment(
        payment,
        subscription: previous,
        plan: plan,
        previousPeriodEnd: previous.currentPeriodEnd,
      );
    });
  }

  Future<void> _handlePayment(
    PaymentInitiation payment, {
    required Subscription subscription,
    required SubscriptionPlan plan,
    DateTime? previousPeriodEnd,
  }) async {
    if (_disposed) return;

    if (!payment.isPending && !payment.isConfirmed) {
      throw StateError('Payment is not available');
    }

    if (payment.isPending && !payment.isStripe) {
      throw StateError('Unsupported payment provider');
    }

    final expected = _PaymentConfirmation(
      subscriptionId: subscription.id,
      planId: plan.id,
      previousPeriodEnd: previousPeriodEnd,
      entitlementCodes: plan.entitlementCodes,
    );

    // Persist renewal information before opening Stripe.
    // Activation recovery is already supported by the backend.
    await _rememberConfirmation(expected);

    if (_disposed) return;

    if (payment.canPresentPaymentSheet) {
      final outcome = await paymentService.present(payment);

      if (_disposed) return;

      if (outcome == PaymentSheetOutcome.cancelled) {
        await _readSummary();

        if (await _resolveConfirmation()) {
          return;
        }

        if (_sameState(subscription, current)) {
          await _clearConfirmation();

          _message = PlanMessage.paymentCancelled;

          return;
        }
      }
    }

    // A confirmed payment or a pending payment without a client
    // secret requires reconciliation, not another PaymentSheet.
    _message = PlanMessage.awaitingConfirmation;
    _emit();

    await _waitForConfirmation();
  }

  Future<void> _waitForConfirmation() async {
    for (var attempt = 0; attempt < 8; attempt++) {
      if (_disposed) return;

      try {
        await _readSummary();

        if (_disposed) return;

        if (await _resolveConfirmation()) {
          return;
        }
      } catch (_) {
        // The backend may still be processing the payment.
      }

      if (attempt < 7) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    _message = PlanMessage.awaitingConfirmation;
  }

  Future<bool> cancelAtPeriodEnd() async {
    if (!canCancel) return false;

    final previous = current!;

    await _run(() async {
      await _readSummary();

      if (_disposed) return;

      if (!_sameState(previous, current)) {
        _message = PlanMessage.stateChanged;
        return;
      }

      await repository.requestCancellation(previous.id);

      await _readSummary();

      if (current?.isCancellationScheduled == true) {
        _message = PlanMessage.cancellationSucceeded;
      } else {
        throw StateError('Cancellation not confirmed');
      }
    });

    return _message == PlanMessage.cancellationSucceeded;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class _PaymentConfirmation {
  final String subscriptionId;
  final String planId;
  final DateTime? previousPeriodEnd;
  final List<String> entitlementCodes;

  const _PaymentConfirmation({
    required this.subscriptionId,
    required this.planId,
    required this.previousPeriodEnd,
    required this.entitlementCodes,
  });

  factory _PaymentConfirmation.fromJson(Map<String, dynamic> json) {
    final previousEnd = json['previousPeriodEnd'] as String?;

    return _PaymentConfirmation(
      subscriptionId: json['subscriptionId'] as String,
      planId: json['planId'] as String,
      previousPeriodEnd: previousEnd == null
          ? null
          : DateTime.parse(previousEnd),
      entitlementCodes: List<String>.unmodifiable(
        (json['entitlementCodes'] as List).cast<String>(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'planId': planId,
      'previousPeriodEnd': previousPeriodEnd?.toUtc().toIso8601String(),
      'entitlementCodes': entitlementCodes,
    };
  }

  bool matches(SubscriptionSummary? summary) {
    if (summary == null) return false;

    final subscription = summary.subscription;

    if (subscription.id != subscriptionId ||
        subscription.planId != planId ||
        !subscription.isActive) {
      return false;
    }

    final previousEnd = previousPeriodEnd;
    final currentEnd = subscription.currentPeriodEnd;

    if (currentEnd == null) return false;

    if (previousEnd != null && !currentEnd.isAfter(previousEnd)) {
      return false;
    }

    return entitlementCodes.every(summary.hasEntitlement);
  }
}
