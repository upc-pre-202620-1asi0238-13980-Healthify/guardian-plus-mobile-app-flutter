import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';
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
  @override
  void initState() {
    super.initState();

    widget.viewModel.addListener(_refresh);
    widget.viewModel.load();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_refresh);
    widget.viewModel.dispose();

    super.dispose();
  }

  String _date(DateTime value) {
    return MaterialLocalizations.of(context).formatMediumDate(value.toLocal());
  }

  String _status(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return context.l10n.myPlanStatusActive;

      case 'PENDING':
        return context.l10n.myPlanStatusPending;

      case 'CANCELLED':
      case 'CANCELED':
        return context.l10n.myPlanStatusCancelled;

      case 'EXPIRED':
        return context.l10n.myPlanStatusExpired;

      default:
        return value;
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.myPlanCancelTitle),
        content: Text(context.l10n.myPlanCancelBody),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: Text(context.l10n.myPlanKeepPlan),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: Text(context.l10n.myPlanConfirmCancel),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.viewModel.cancelAtPeriodEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.viewModel;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            ProfileTopBar(
              title: l10n.profileMyPlan,
              subtitle: l10n.profileMyPlanSubtitle,
              onBack: widget.onBack,
            ),

            const SizedBox(height: 24),

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
            else if (state.summary == null)
              ProfileInfoBanner(text: l10n.myPlanNoSubscription)
            else ...[
              ProfileSectionTitle(title: l10n.myPlanCurrent),

              ProfileCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.myPlanGuardianPlan,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      '${l10n.myPlanStatus}: '
                      '${_status(state.summary!.subscription.status)}',
                    ),

                    const SizedBox(height: 7),

                    Text(
                      '${l10n.myPlanPeriod}: '
                      '${_date(state.summary!.subscription.currentPeriodStart)}'
                      ' — '
                      '${_date(state.summary!.subscription.currentPeriodEnd)}',
                    ),

                    const SizedBox(height: 7),

                    Text(
                      '${l10n.myPlanPlanId}: '
                      '${state.summary!.subscription.planId}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              ProfileSectionTitle(title: l10n.myPlanBenefits),

              ProfileCard(
                padding: EdgeInsets.zero,
                child: state.summary!.entitlements.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(l10n.myPlanNoBenefits),
                      )
                    : Column(
                        children: [
                          for (final entitlement in state.summary!.entitlements)
                            ListTile(
                              leading: const Icon(
                                Icons.check_circle_outline_rounded,
                              ),
                              title: Text(
                                entitlement.name.isEmpty
                                    ? entitlement.code
                                    : entitlement.name,
                              ),
                              subtitle: entitlement.description.isEmpty
                                  ? null
                                  : Text(entitlement.description),
                            ),
                        ],
                      ),
              ),

              const SizedBox(height: 20),

              if (state.summary!.subscription.cancelAtPeriodEnd)
                ProfileInfoBanner(
                  text:
                      '${l10n.myPlanCancellationScheduled} '
                      '${_date(state.summary!.subscription.currentPeriodEnd)}.',
                )
              else if (state.summary!.subscription.canRequestCancellation)
                OutlinedButton.icon(
                  onPressed: state.isCancelling ? null : _cancel,
                  icon: const Icon(Icons.event_busy_outlined),
                  label: Text(l10n.myPlanCancelAction),
                ),

              if (state.cancellationSucceeded) ...[
                const SizedBox(height: 14),
                ProfileInfoBanner(text: l10n.myPlanCancellationSuccess),
              ],

              if (state.cancellationFailed) ...[
                const SizedBox(height: 14),
                Text(
                  l10n.myPlanCancellationError,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
