import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/adherence.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_status.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_banner.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_card.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_progress_bar.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_timeline_item.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_tone.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_top_bar.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/medication/medication_state.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/medication/medication_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/navigation/care_routines_wellness_navigation.dart';

class MedicationPage extends StatefulWidget {
  final MedicationViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  late final MedicationViewModel _viewModel = widget.viewModel;

  @override
  void dispose() {
    // The page owns its view model: every visit starts with a fresh one (registerFactory)
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openForm() async {
    final message = await openMedicationForm(context);
    if (message != null) _viewModel.onFormResult(message);
  }

  // Marking a dose as missed closes it for good, so it is asked first
  Future<void> _reviewDose(Reminder dose) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Marcar ${dose.displayTitle} como omitida?'),
        content: Text(
          'Hazlo si ya verificaste que ${_viewModel.careRecipientFirstName} no tomó esta dosis. '
          'No se descontará del stock.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Marcar como omitida')),
        ],
      ),
    );
    if (confirmed == true) _viewModel.markDoseAsMissed(dose);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoutineTopBar(
        title: 'Medicación',
        subtitle: 'Tratamiento y adherencia',
        onBackPressed: () => Navigator.pop(context),
        action: RoutineTopBarButton(icon: Icons.add, tooltip: 'Nueva toma', onPressed: _openForm),
      ),
      body: RoutineMessageEffect(
        source: _viewModel,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            final state = _viewModel.state;
            return switch (state) {
              MedicationState(isLoaded: false, errorMessage: null) => const RoutineLoadingState(),
              MedicationState(isLoaded: false) => RoutineErrorState(
                message: state.errorMessage ?? '',
                onRetry: _viewModel.load,
              ),
              _ => _MedicationList(
                state: state,
                careRecipientFirstName: _viewModel.careRecipientFirstName,
                onAddDose: _openForm,
                onConfirmDose: _viewModel.confirmDose,
                onReviewDose: _reviewDose,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _MedicationList extends StatelessWidget {
  final MedicationState state;
  final String careRecipientFirstName;
  final VoidCallback onAddDose;
  final ValueChanged<Reminder> onConfirmDose;
  final ValueChanged<Reminder> onReviewDose;

  const new({
    required this.state,
    required this.careRecipientFirstName,
    required this.onAddDose,
    required this.onConfirmDose,
    required this.onReviewDose,
  });

  @override
  Widget build(BuildContext context) {
    final doses = state.doses;
    final nextDose = state.nextDose;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        if (nextDose != null) ...[
          _NextDoseBanner(dose: nextDose, now: state.now, careRecipientFirstName: careRecipientFirstName),
          const SizedBox(height: 10),
        ],
        RoutineSectionTitle(
          text: 'Hoy',
          trailing: doses.isEmpty ? null : RoutineBadge(text: '${state.takenCount} de ${doses.length} tomadas'),
        ),
        if (doses.isEmpty)
          RoutineEmptyState(
            icon: Icons.medication_outlined,
            title: 'Sin tomas para hoy',
            message: 'Programa un medicamento para que la pulsera avise a la hora de cada toma.',
            actionLabel: 'Nueva toma',
            onAction: onAddDose,
          ),
        for (final dose in doses) ...[
          const SizedBox(height: 10),
          _DoseItem(
            key: ValueKey(dose.id),
            dose: dose,
            isNext: dose.id == nextDose?.id,
            isBusy: state.busyReminderId == dose.id,
            onConfirm: () => onConfirmDose(dose),
          ),
        ],
        for (final dose in state.unconfirmedDoses) ...[
          const SizedBox(height: 10),
          RoutineBanner(
            key: ValueKey('review-${dose.id}'),
            icon: Icons.warning_amber_rounded,
            title: 'Dosis pendiente: ${dose.displayTitle}',
            message: 'No se confirmó en 10 minutos. Se envió una segunda alerta a la pulsera.',
            tone: RoutineTone.orange,
            actionLabel: 'Revisar',
            isActionLoading: state.busyReminderId == dose.id,
            onAction: () => onReviewDose(dose),
          ),
        ],
        const SizedBox(height: 10),
        const RoutineSectionTitle(text: 'Adherencia semanal'),
        const SizedBox(height: 10),
        _WeeklyAdherenceCard(adherence: state.weeklyAdherence),
      ],
    );
  }
}

class _NextDoseBanner extends StatelessWidget {
  final Reminder dose;
  final DateTime now;
  final String careRecipientFirstName;

  const new({required this.dose, required this.now, required this.careRecipientFirstName});

  @override
  Widget build(BuildContext context) {
    final issued = dose.status != ReminderStatus.scheduled;
    return RoutineBanner(
      icon: Icons.notifications_none,
      title: issued ? 'Es hora de ${dose.displayTitle}' : 'Próxima toma en ${durationUntil(dose.scheduledTime, now)}',
      message: issued
          ? 'Esperando que $careRecipientFirstName confirme la toma en la pulsera.'
          : 'La pulsera avisará a la hora de la toma.',
      tone: RoutineTone.yellow,
    );
  }
}

class _DoseItem extends StatelessWidget {
  final Reminder dose;
  final bool isNext;
  final bool isBusy;
  final VoidCallback onConfirm;

  const new({super.key, required this.dose, required this.isNext, required this.isBusy, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final confirmedAt = dose.confirmedAt;
    final (state, badge, tone) = switch (dose.status) {
      ReminderStatus.confirmed => (TimelineState.done, 'Tomada', RoutineTone.mint),
      ReminderStatus.missed => (TimelineState.missed, 'Omitida', RoutineTone.orange),
      ReminderStatus.issued => (TimelineState.current, 'Pendiente', RoutineTone.yellow),
      ReminderStatus.reissued => (TimelineState.current, 'Reenviada', RoutineTone.orange),
      _ when isNext => (TimelineState.current, 'Próxima', RoutineTone.yellow),
      _ => (TimelineState.upcoming, 'Programada', RoutineTone.muted),
    };
    return RoutineTimelineItem(
      time: formatClockTime(dose.scheduledTime),
      icon: Icons.medication_outlined,
      title: dose.displayTitle,
      detail: confirmedAt != null ? 'Confirmada · ${formatClockTime(confirmedAt)}' : dose.detailLine,
      badge: badge,
      badgeTone: tone,
      state: state,
      actionLabel: dose.canBeConfirmed ? 'Confirmar toma' : null,
      isActionLoading: isBusy,
      onAction: onConfirm,
    );
  }
}

/// "92% · 22 de 24 dosis confirmadas" over the last seven days.
class _WeeklyAdherenceCard extends StatelessWidget {
  final Adherence? adherence;

  const new({required this.adherence});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final mutedStyle = text.bodySmall?.copyWith(color: colors.onSurfaceVariant);
    final adherence = this.adherence;

    return RoutineCard(
      children: [
        if (adherence == null)
          Text('No se pudo calcular la adherencia por ahora.', style: mutedStyle)
        else if (!adherence.hasDueReminders)
          Text('Sin dosis avisadas en los últimos 7 días.', style: mutedStyle)
        else ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${adherence.percentage}%', style: routineMetricStyle.copyWith(color: colors.onSurface)),
                    Text('${adherence.confirmed} de ${adherence.due} dosis confirmadas', style: mutedStyle),
                  ],
                ),
              ),
              AdherenceBadge(percentage: adherence.percentage),
            ],
          ),
          const SizedBox(height: 12),
          RoutineProgressBar(percentage: adherence.percentage),
        ],
      ],
    );
  }
}

/// "Buen progreso" from 80%, "Regular" from 50%, "Requiere atención" below.
class AdherenceBadge extends StatelessWidget {
  final int percentage;

  const new({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final tone = percentage >= 80
        ? RoutineTone.mint
        : percentage >= 50
        ? RoutineTone.yellow
        : RoutineTone.orange;
    return RoutineBadge(text: adherenceLabel(percentage), tone: tone);
  }
}
