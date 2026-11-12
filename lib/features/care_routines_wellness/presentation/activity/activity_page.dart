import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/adherence.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/local_time.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_status.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/activity/activity_state.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/activity/activity_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_card.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_form_fields.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_form_layout.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_progress_bar.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_timeline_item.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_tone.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_top_bar.dart';

// "Duración" options of the prototype, in minutes
const _durations = [5, 10, 15];

class ActivityPage extends StatefulWidget {
  final ActivityViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late final ActivityViewModel _viewModel = widget.viewModel;

  @override
  void dispose() {
    // The page owns its view model: every visit starts with a fresh one (registerFactory)
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        final state = _viewModel.state;
        return Scaffold(
          appBar: RoutineTopBar(
            title: 'Actividad ligera',
            subtitle: 'Movilidad y pausas activas',
            onBackPressed: () => Navigator.pop(context),
            action: RoutineTopBarButton(
              icon: state.isAdding ? Icons.close : Icons.add,
              tooltip: state.isAdding ? 'Cancelar' : 'Nueva actividad',
              onPressed: _viewModel.toggleAdding,
            ),
          ),
          body: RoutineMessageEffect(
            source: _viewModel,
            child: switch (state) {
              ActivityState(isLoaded: false, errorMessage: null) => const RoutineLoadingState(),
              ActivityState(isLoaded: false) => RoutineErrorState(
                message: state.errorMessage ?? '',
                onRetry: _viewModel.load,
              ),
              ActivityState(isAdding: true) => _AddActivityForm(
                isSaving: state.isSaving,
                isLaterToday: _viewModel.isLaterToday,
                onAdd: _viewModel.addActivity,
              ),
              _ => _ActivityList(state: state, viewModel: _viewModel),
            },
          ),
        );
      },
    );
  }
}

class _ActivityList extends StatelessWidget {
  final ActivityState state;
  final ActivityViewModel viewModel;

  const new({required this.state, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final blocks = state.blocks;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _ActivityHeroCard(completed: state.completedCount, total: blocks.length, percentage: state.percentage),
        const SizedBox(height: 10),
        const RoutineSectionTitle(text: 'Plan de hoy'),
        if (blocks.isEmpty)
          RoutineEmptyState(
            icon: Icons.directions_walk,
            title: 'Sin actividades hoy',
            message: 'Añade una pausa activa para que la pulsera la recuerde.',
            actionLabel: 'Nueva actividad',
            onAction: viewModel.toggleAdding,
          ),
        for (final block in blocks) ...[
          const SizedBox(height: 10),
          _ActivityBlockItem(
            key: ValueKey(block.id),
            block: block,
            isNext: block.id == state.nextBlock?.id,
            isBusy: state.busyReminderId == block.id,
            onComplete: () => viewModel.completeBlock(block),
          ),
        ],
        const SizedBox(height: 10),
        const RoutineSectionTitle(text: 'Cumplimiento de actividad ligera'),
        const SizedBox(height: 10),
        _WeeklyActivityCard(adherence: state.weeklyAdherence),
      ],
    );
  }
}

/// Green card "PROGRESO DE HOY · 2 de 3 completadas" with the daily adherence bar.
class _ActivityHeroCard extends StatelessWidget {
  final int completed;
  final int total;
  final int percentage;

  const new({required this.completed, required this.total, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(GuardianRadius.medium)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(GuardianRadius.medium),
                ),
                child: Icon(Icons.directions_walk, size: 26, color: colors.onPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROGRESO DE HOY', style: dataLabelStyle.copyWith(color: colors.onPrimary)),
                    Text('$completed de $total completadas', style: text.titleMedium?.copyWith(color: colors.onPrimary)),
                    Text(
                      'La pulsera avisará al comenzar cada bloque.',
                      style: text.bodySmall?.copyWith(color: colors.primaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RoutineProgressBar(
            percentage: percentage,
            label: 'Adherencia diaria',
            track: colors.onPrimary.withValues(alpha: 0.2),
            progress: colors.primaryContainer,
            textColor: colors.primaryContainer,
          ),
        ],
      ),
    );
  }
}

class _ActivityBlockItem extends StatelessWidget {
  final Reminder block;
  final bool isNext;
  final bool isBusy;
  final VoidCallback onComplete;

  const new({super.key, required this.block, required this.isNext, required this.isBusy, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final duration = block.durationMinutes != null ? '${block.durationMinutes} minutos' : null;
    final confirmedAt = block.confirmedAt;
    final (state, badge, tone) = switch (block.status) {
      ReminderStatus.confirmed => (TimelineState.done, 'Hecha', RoutineTone.mint),
      ReminderStatus.missed => (TimelineState.missed, 'No realizada', RoutineTone.orange),
      ReminderStatus.issued || ReminderStatus.reissued => (TimelineState.current, 'Pendiente', RoutineTone.yellow),
      _ when isNext => (TimelineState.current, 'Próxima', RoutineTone.yellow),
      _ => (TimelineState.upcoming, 'Programada', RoutineTone.muted),
    };
    final second = confirmedAt != null
        ? 'Confirmada ${formatClockTime(confirmedAt)}'
        : block.canBeConfirmed
        ? 'Aviso háptico'
        : null;

    return RoutineTimelineItem(
      time: formatClockTime(block.scheduledTime),
      icon: Icons.directions_walk,
      title: block.displayTitle,
      detail: [?duration, ?second].join(' · '),
      badge: badge,
      badgeTone: tone,
      state: state,
      actionLabel: block.canBeConfirmed ? 'Registrar como completada' : null,
      isActionLoading: isBusy,
      onAction: onComplete,
    );
  }
}

/// Bars of the last seven days, one per day, with the share of blocks that were done.
class _WeeklyActivityCard extends StatelessWidget {
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
        Row(
          children: [
            Expanded(
              child: Text('Sesiones de movilidad', style: text.titleSmall?.copyWith(color: colors.onSurface)),
            ),
            Text('Últimos 7 días', style: text.labelMedium?.copyWith(color: colors.onSurfaceVariant)),
          ],
        ),
        if (adherence == null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('No se pudo calcular la adherencia por ahora.', style: mutedStyle),
          )
        else ...[
          const SizedBox(height: 14),
          _WeekBars(days: adherence.days),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Text(
              adherence.hasDueReminders
                  ? '${adherence.confirmed} ejercicios de movilidad completados · '
                        '${adherence.percentage}% de adherencia'
                  : 'Sin actividades avisadas en los últimos 7 días',
              textAlign: TextAlign.center,
              style: mutedStyle,
            ),
          ),
        ],
      ],
    );
  }
}

class _WeekBars extends StatelessWidget {
  final List<DailyAdherence> days;

  const new({required this.days});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 118,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (index, day) in days.indexed) ...[
            if (index > 0) const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // A day without blocks keeps a stub so the week still reads as seven days
                  Container(
                    height: max(90 * (day.due == 0 ? 0 : day.percentage / 100), 6),
                    decoration: BoxDecoration(
                      color: day.due == 0 ? colors.surfaceContainerHighest : colors.secondary,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(5), bottom: Radius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    weekdayInitial(day.date.weekday),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "Nueva actividad": a block for later today.
class _AddActivityForm extends StatefulWidget {
  final bool isSaving;
  final bool Function(LocalTime time) isLaterToday;
  final Future<void> Function({required String name, required LocalTime time, required int durationMinutes}) onAdd;

  const new({required this.isSaving, required this.isLaterToday, required this.onAdd});

  @override
  State<_AddActivityForm> createState() => _AddActivityFormState();
}

class _AddActivityFormState extends State<_AddActivityForm> {
  String _name = '';
  // The next o'clock hour, the usual time of a new block
  LocalTime _time = LocalTime(hour: (DateTime.now().hour + 1) % 24, minute: 0);
  int _duration = _durations[1];
  bool _showErrors = false;

  bool get _nameValid => _name.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final timeValid = widget.isLaterToday(_time);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
      children: [
        RoutineFormSection(
          title: 'Nueva actividad',
          children: [
            RoutineTextField(
              label: 'Actividad',
              value: _name,
              onChanged: (value) => setState(() => _name = value),
              placeholder: 'Ej. Caminata suave',
              errorMessage: _showErrors && !_nameValid ? 'Escribe el nombre de la actividad' : null,
            ),
            RoutineTimeField(
              label: 'Hora del aviso',
              value: _time,
              errorMessage: _showErrors && !timeValid ? 'Elige una hora que aún no haya pasado' : null,
              onChanged: (time) => setState(() => _time = time),
            ),
            RoutineSelectField<int>(
              label: 'Duración',
              options: _durations,
              selected: _duration,
              optionLabel: (minutes) => '$minutes minutos',
              onSelect: (minutes) => setState(() => _duration = minutes),
            ),
            RoutinePrimaryButton(
              text: 'Añadir al plan',
              isLoading: widget.isSaving,
              onPressed: () {
                setState(() => _showErrors = true);
                if (_nameValid && timeValid) widget.onAdd(name: _name, time: _time, durationMinutes: _duration);
              },
            ),
          ],
        ),
      ],
    );
  }
}
