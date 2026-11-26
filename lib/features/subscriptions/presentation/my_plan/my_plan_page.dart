import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';
import 'package:guardian_plus_app/features/subscriptions/domain/subscription.dart';
import 'package:guardian_plus_app/features/subscriptions/presentation/my_plan/my_plan_view_model.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

class MyPlanPage extends StatefulWidget {
  final MyPlanViewModel viewModel;
  final VoidCallback onBack;

  const MyPlanPage({super.key, required this.viewModel, required this.onBack});

  @override
  State<MyPlanPage> createState() => _MyPlanPageState();
}

class _MyPlanPageState extends State<MyPlanPage> {
  MyPlanViewModel get state => widget.viewModel;

  @override
  void initState() {
    super.initState();
    state.addListener(_refresh);
    state.load();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    state.removeListener(_refresh);
    state.dispose();
    super.dispose();
  }

  String _date(DateTime? value) {
    if (value == null) return '-';

    return MaterialLocalizations.of(context).formatMediumDate(value.toLocal());
  }

  String _status(String value) {
    final l10n = context.l10n;

    return switch (value.toUpperCase()) {
      'ACTIVE' => l10n.myPlanStatusActive,
      'PENDING' => l10n.myPlanStatusPending,
      'CANCELLATION_SCHEDULED' => l10n.subscriptionScheduled,
      'CANCELLED' || 'CANCELED' => l10n.myPlanStatusCancelled,
      'EXPIRED' => l10n.myPlanStatusExpired,
      _ => value,
    };
  }

  String _price(SubscriptionPlan plan) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final currency = plan.currency.toUpperCase();

    if (plan.isFree) {
      return l10n.subscriptionFree;
    }

    final amount = currency == 'PEN'
        ? 'S/ ${NumberFormat.decimalPatternDigits(locale: locale.languageCode == 'es' ? 'es_PE' : locale.toString(), decimalDigits: 2).format(plan.price)}'
        : NumberFormat.simpleCurrency(
            locale: locale.toString(),
            name: currency,
          ).format(plan.price);

    final cycle = switch (plan.billingCycle.toUpperCase()) {
      'MONTHLY' => l10n.subscriptionMonthly,
      'ANNUAL' || 'YEARLY' => l10n.subscriptionAnnual,
      _ => '',
    };

    return cycle.isEmpty ? amount : '$amount $cycle';
  }

  String _benefit(String code) {
    final l10n = context.l10n;

    return switch (code) {
      'BASIC_REMINDERS' => l10n.subscriptionBenefitReminders,
      'EMERGENCY_ALERTS' => l10n.subscriptionBenefitEmergency,
      'FALL_DETECTION' => l10n.subscriptionBenefitFall,
      'GEOFENCING' => l10n.subscriptionBenefitGeofence,
      'HEALTH_MONITORING' => l10n.subscriptionBenefitHealth,
      'REAL_TIME_LOCATION' => l10n.subscriptionBenefitLocation,
      'LOCATION_HISTORY' => l10n.subscriptionBenefitLocationHistory,
      'SLEEP_ACTIVITY_MONITORING' => l10n.subscriptionBenefitSleep,
      'TREATMENT_ADHERENCE' => l10n.subscriptionBenefitTreatment,
      'VITAL_SIGNS_HISTORY' => l10n.subscriptionBenefitVitals,
      _ => code,
    };
  }

  String? _message() {
    final l10n = context.l10n;

    return switch (state.message) {
      PlanMessage.updated => l10n.subscriptionUpdated,
      PlanMessage.paymentCancelled => l10n.subscriptionPaymentCancelled,
      PlanMessage.awaitingConfirmation => l10n.subscriptionAwaitingConfirmation,
      PlanMessage.failed => l10n.subscriptionOperationFailed,
      PlanMessage.stripeNotConfigured => l10n.subscriptionStripeNotConfigured,
      PlanMessage.stateChanged => l10n.subscriptionStateChanged,
      PlanMessage.cancellationSucceeded => l10n.myPlanCancellationSuccess,
      null => null,
    };
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required String confirmLabel,
    String? planName,
    String? amount,
  }) async {
    final backLabel = context.l10n.subscriptionBack;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (planName != null) ...[
                Text(
                  planName,
                  style: Theme.of(dialogContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
              ],
              if (amount != null) ...[
                Text(
                  amount,
                  style: Theme.of(dialogContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
              ],
              Text(body),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(backLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    return mounted && confirmed == true;
  }

  Future<void> _select(SubscriptionPlan plan) async {
    final l10n = context.l10n;

    final confirmed = await _confirm(
      title: l10n.subscriptionConfirmSelection,
      body: plan.requiresPayment
          ? l10n.subscriptionConfirmPaidBody
          : l10n.subscriptionConfirmFreeBody,
      confirmLabel: l10n.subscriptionContinue,
      planName: plan.name,
      amount: _price(plan),
    );

    if (mounted && confirmed) {
      await state.selectPlan(plan);
    }
  }

  Future<void> _renew() async {
    final plan = state.currentPlan;

    if (plan == null) return;

    final l10n = context.l10n;

    final confirmed = await _confirm(
      title: l10n.subscriptionConfirmRenewal,
      body: l10n.subscriptionRenewalBody,
      confirmLabel: l10n.subscriptionContinue,
      planName: plan.name,
      amount: _price(plan),
    );

    if (mounted && confirmed) {
      await state.renew();
    }
  }

  Future<void> _cancel() async {
    final l10n = context.l10n;

    final confirmed = await _confirm(
      title: l10n.myPlanCancelTitle,
      body: l10n.myPlanCancelBody,
      confirmLabel: l10n.myPlanConfirmCancel,
    );

    if (mounted && confirmed) {
      await state.cancelAtPeriodEnd();
    }
  }

  Widget _currentSubscription() {
    final l10n = context.l10n;
    final summary = state.summary;
    final theme = Theme.of(context);

    if (summary == null) {
      return ProfileInfoBanner(text: l10n.myPlanNoSubscription);
    }

    final subscription = summary.subscription;
    final plan = state.currentPlan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileSectionTitle(title: l10n.myPlanCurrent),
        ProfileCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      plan?.name ?? l10n.myPlanGuardianPlan,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              if (plan != null) ...[
                const SizedBox(height: 12),
                Text(_price(plan), style: theme.textTheme.headlineSmall),
              ],
              const SizedBox(height: 14),
              Text(
                '${l10n.myPlanStatus}: '
                '${_status(subscription.status)}',
              ),
              if (subscription.currentPeriodEnd != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${l10n.myPlanPeriod}: '
                  '${_date(subscription.currentPeriodStart)}'
                  ' - '
                  '${_date(subscription.currentPeriodEnd)}',
                ),
              ],
            ],
          ),
        ),
        if (subscription.isPending) ...[
          const SizedBox(height: 12),
          ProfileInfoBanner(text: l10n.subscriptionPendingNotice),
        ],
        const SizedBox(height: 20),
        ProfileSectionTitle(title: l10n.myPlanBenefits),
        ProfileCard(
          padding: EdgeInsets.zero,
          child: summary.entitlements.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.myPlanNoBenefits),
                )
              : Column(
                  children: [
                    for (final item in summary.entitlements)
                      ListTile(
                        leading: Icon(
                          Icons.check_circle_outline,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(_benefit(item.code)),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        if (subscription.isCancellationScheduled)
          ProfileInfoBanner(
            text:
                '${l10n.myPlanCancellationScheduled} '
                '${_date(subscription.currentPeriodEnd)}.',
          )
        else if (subscription.isActive) ...[
          if (plan?.requiresPayment == true)
            FilledButton.icon(
              onPressed: state.canRenew ? _renew : null,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.subscriptionRenew),
            ),
          if (subscription.canRequestCancellation)
            OutlinedButton.icon(
              onPressed: state.canCancel ? _cancel : null,
              icon: const Icon(Icons.event_busy_outlined),
              label: Text(l10n.myPlanCancelAction),
            ),
        ],
      ],
    );
  }

  Widget _planCard(SubscriptionPlan plan) {
    final l10n = context.l10n;
    final current = state.current;
    final theme = Theme.of(context);

    final samePlan = current?.planId == plan.id;
    final pending = current?.isPending == true;

    final String label;

    if (samePlan && pending && plan.requiresPayment) {
      label = l10n.subscriptionResumePayment;
    } else if (samePlan && !pending) {
      label = l10n.subscriptionSelected;
    } else {
      label = l10n.subscriptionSelect;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ProfileCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  plan.isFree
                      ? Icons.shield_outlined
                      : Icons.star_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(plan.name, style: theme.textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_price(plan), style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Divider(),
            for (final code in plan.entitlementCodes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_benefit(code))),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: state.canSelectPlan(plan) ? () => _select(plan) : null,
              child: Text(label),
            ),
            if (!samePlan && current?.isActive == true && plan.requiresPayment)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.subscriptionPaidChangeUnavailable,
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message = _message();

    return PopScope(
      canPop: !state.isBusy,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            children: [
              ProfileTopBar(
                title: l10n.profileMyPlan,
                subtitle: l10n.profileMyPlanSubtitle,
                onBack: () {
                  if (!state.isBusy) {
                    widget.onBack();
                  }
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: state.isLoading || state.isBusy
                      ? null
                      : state.load,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.subscriptionRefresh),
                ),
              ),
              if (state.isBusy) const LinearProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 12),
                ProfileInfoBanner(text: message),
              ],
              const SizedBox(height: 16),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (state.loadFailed)
                ProfileCard(
                  child: Column(
                    children: [
                      Text(l10n.myPlanLoadError, textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: state.load,
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
                )
              else ...[
                _currentSubscription(),
                const SizedBox(height: 24),
                ProfileSectionTitle(title: l10n.subscriptionCatalogTitle),
                if (state.plans.isEmpty)
                  ProfileInfoBanner(text: l10n.subscriptionCatalogEmpty)
                else
                  for (final plan in state.plans) _planCard(plan),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
