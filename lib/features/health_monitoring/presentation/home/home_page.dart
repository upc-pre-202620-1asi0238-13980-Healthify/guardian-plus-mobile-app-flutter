import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/error_state.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/live_vitals_state.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/home/components/care_recipient_card.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/home/components/home_header.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/home/components/quick_actions_row.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/home/components/section_title.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/home/components/status_hero_card.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/home/components/upcoming_card.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/home/components/vitals_summary_card.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/live_vitals/live_vitals_view_model.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/wearable/link_wearable_sheet.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/wearable/link_wearable_view_model.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/wearable/wearable_details_page.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/wearable/wearable_details_view_model.dart';

/// "Inicio" tab: how the care recipient is doing right now. Only reads live vitals, so no view model of its own.
class HomePage extends StatefulWidget {
  final LiveVitalsViewModel viewModel;
  final VoidCallback onSeeVitalsTap;
  final VoidCallback onAlertsTap;

  const new({super.key, required this.viewModel, required this.onSeeVitalsTap, required this.onAlertsTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final LiveVitalsViewModel _viewModel = widget.viewModel;

  @override
  void dispose() {
    // The page owns its view model (registerFactory)
    _viewModel.dispose();
    super.dispose();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Próximamente')));
  }

  Future<void> _linkWristband() async {
    final linked = await showLinkWearableSheet(
      context,
      viewModel: getIt<LinkWearableViewModel>(),
      careRecipientFirstName: _viewModel.careContext.careRecipientFirstName,
    );
    if (!linked || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dispositivo vinculado')));
    _viewModel.load();
  }

  // A wristband linked or replaced there shows up here when coming back
  Future<void> _openWristband() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => WearableDetailsPage(viewModel: getIt<WearableDetailsViewModel>()),
      ),
    );
    if (mounted) _viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            final state = _viewModel.state;
            return switch (state) {
              // Old readings stay visible during refreshes; the spinner is only for the very first load
              LiveVitalsState(vitals: null, isLoading: true) => const Center(child: CircularProgressIndicator()),
              LiveVitalsState(vitals: null) => ErrorState(
                message: state.errorMessage ?? 'La pulsera aún no envió lecturas',
                onRetry: _viewModel.load,
              ),
              _ => _HomeContent(
                viewModel: _viewModel,
                onBellTap: widget.onAlertsTap,
                onSeeVitalsTap: widget.onSeeVitalsTap,
                onComingSoon: _showComingSoon,
                onLinkWristbandTap: _linkWristband,
                onWristbandTap: _openWristband,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final LiveVitalsViewModel viewModel;
  final VoidCallback onBellTap;
  final VoidCallback onSeeVitalsTap;
  final VoidCallback onComingSoon;
  final VoidCallback onLinkWristbandTap;
  final VoidCallback onWristbandTap;

  const new({
    required this.viewModel,
    required this.onBellTap,
    required this.onSeeVitalsTap,
    required this.onComingSoon,
    required this.onLinkWristbandTap,
    required this.onWristbandTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = viewModel.state;
    final careContext = viewModel.careContext;
    final vitals = state.vitals!;
    const gap = SizedBox(height: 16);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        HomeHeader(
          userInitials: viewModel.userInitials,
          userFirstName: careContext.userFirstName,
          careRecipientFirstName: state.careRecipientFirstName,
          allWithinRange: state.allWithinRange,
          hour: state.now.toLocal().hour,
          onBellTap: onBellTap,
        ),
        gap,
        CareRecipientCard(
          name: careContext.careRecipientName,
          hasLiveSignal: state.hasLiveSignal,
          onChangeTap: onComingSoon,
        ),
        gap,
        StatusHeroCard(
          careRecipientFirstName: state.careRecipientFirstName,
          allWithinRange: state.allWithinRange,
          hasLiveSignal: state.hasLiveSignal,
          updatedText: relativeTime(vitals.retrievedAt, state.now),
          hasWristband: state.hasWristband,
          onLinkWristbandTap: onLinkWristbandTap,
          onWristbandTap: onWristbandTap,
        ),
        gap,
        // The app has no dialer, video call or location yet
        QuickActionsRow(onCallTap: onComingSoon, onVideoTap: onComingSoon, onLocationTap: onComingSoon),
        gap,
        SectionTitle(title: 'Signos vitales', action: 'Ver detalle', onActionTap: onSeeVitalsTap),
        gap,
        VitalsSummaryCard(
          vitals: vitals,
          bloodPressureText: state.bloodPressureText,
          bloodPressureOutOfRange: state.bloodPressureOutOfRange,
          now: state.now,
        ),
        gap,
        SectionTitle(title: 'Lo próximo', action: 'Ver agenda', onActionTap: onComingSoon),
        gap,
        const UpcomingCard(),
      ],
    );
  }
}
