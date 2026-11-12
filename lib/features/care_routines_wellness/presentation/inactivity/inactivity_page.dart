import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_log_entry.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_monitor.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_status.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_banner.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_card.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_form_fields.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_settings_card.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_tone.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_top_bar.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/inactivity/inactivity_state.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/inactivity/inactivity_view_model.dart';

// "Alertar después de" options of the prototype, inside the platform's 30–240 minutes
const _thresholdOptions = [60, 90, 120];

class InactivityPage extends StatefulWidget {
  final InactivityViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<InactivityPage> createState() => _InactivityPageState();
}

class _InactivityPageState extends State<InactivityPage> {
  late final InactivityViewModel _viewModel = widget.viewModel;

  @override
  void dispose() {
    // The page owns its view model: every visit starts with a fresh one (registerFactory)
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoutineTopBar(
        title: 'Inactividad',
        subtitle: 'Detección de inmovilidad',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: RoutineMessageEffect(
        source: _viewModel,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            final state = _viewModel.state;
            return switch (state) {
              InactivityState(isLoaded: false, errorMessage: null) => const RoutineLoadingState(),
              InactivityState(isLoaded: false) => RoutineErrorState(
                message: state.errorMessage ?? '',
                onRetry: _viewModel.load,
              ),
              _ => ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  _ActivityStatusCard(monitor: state.monitor, now: state.now),
                  const SizedBox(height: 10),
                  const RoutineSectionTitle(text: 'Vigilancia diurna'),
                  const SizedBox(height: 10),
                  _WatchSettingsCard(state: state, viewModel: _viewModel),
                  const SizedBox(height: 10),
                  RoutineBanner(
                    icon: Icons.warning_amber_rounded,
                    title: '¿Qué ocurre al llegar a ${state.thresholdMinutes} min?',
                    message:
                        'Recibirás un aviso preventivo para verificar el estado de '
                        '${_viewModel.careRecipientFirstName}.',
                    tone: RoutineTone.orange,
                  ),
                  const SizedBox(height: 10),
                  const RoutineBanner(
                    icon: Icons.directions_walk,
                    title: 'Reinicio automático',
                    message: 'Al detectar marcha o desplazamiento, el contador vuelve a cero sin generar alarma.',
                    tone: RoutineTone.mint,
                  ),
                  const SizedBox(height: 10),
                  const RoutineSectionTitle(text: 'Actividad reciente'),
                  const SizedBox(height: 10),
                  _RecentActivityCard(entries: state.recentActivity),
                ],
              ),
            };
          },
        ),
      ),
    );
  }
}

/// Green while the person moves, orange once prolonged inactivity is detected.
class _ActivityStatusCard extends StatelessWidget {
  final ActivityMonitor? monitor;
  final DateTime now;

  const new({required this.monitor, required this.now});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final monitor = this.monitor;
    final inactive = monitor?.status == ActivityStatus.inactivityDetected;
    final container = monitor == null
        ? colors.surfaceContainerHighest
        : inactive
        ? colors.tertiary
        : colors.primary;
    final content = monitor == null ? colors.onSurfaceVariant : colors.onPrimary;
    final softContent = monitor == null ? colors.onSurfaceVariant : colors.primaryContainer;
    final lastMovementAt = monitor?.lastMovementAt;
    final inactivitySince = monitor?.inactivitySince;

    final title = monitor == null
        ? 'Sin datos de la pulsera'
        : inactive
        ? 'Inactividad prolongada'
        : 'Actividad normal';
    final String detail;
    if (monitor == null) {
      detail = 'La vigilancia empezará con los primeros datos de actividad.';
    } else if (inactive && inactivitySince != null) {
      detail = 'Sin movimiento desde las ${formatClockTime(inactivitySince)}.';
    } else if (lastMovementAt != null) {
      final ago = relativeTime(lastMovementAt, now);
      detail = 'Último movimiento detectado ${ago[0].toLowerCase()}${ago.substring(1)}.';
    } else {
      detail = 'Aún no se detectó movimiento.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: container, borderRadius: BorderRadius.circular(GuardianRadius.medium)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: content.withValues(alpha: 0.13),
            child: Icon(inactive ? Icons.hourglass_empty : Icons.directions_walk, size: 28, color: content),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (monitor != null)
                  RoutineChip(
                    text: inactive ? 'Sin movimiento' : 'En movimiento',
                    container: content.withValues(alpha: 0.18),
                    content: content,
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(title, style: text.titleMedium?.copyWith(color: content)),
                ),
                Text(detail, style: text.bodySmall?.copyWith(color: softContent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchSettingsCard extends StatelessWidget {
  final InactivityState state;
  final InactivityViewModel viewModel;

  const new({required this.state, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final monitor = state.monitor;
    final watchStart = monitor?.watchHoursStart;
    final watchEnd = monitor?.watchHoursEnd;
    final enabled = !state.isSaving;

    return RoutineSettingsCard(
      children: [
        RoutineSwitchRow(
          title: 'Detección activa',
          detail: watchStart != null && watchEnd != null
              ? 'Durante la jornada de ${formatTimeOfDay(watchStart)} a ${formatTimeOfDay(watchEnd)}'
              : 'Fuera de las horas de sueño',
          value: state.detectionEnabled,
          enabled: enabled,
          onChanged: viewModel.setDetectionEnabled,
        ),
        RoutineSelectField<int>(
          padding: routineSettingsRowPadding,
          label: 'Alertar después de',
          // A threshold set elsewhere (e.g. 45 through the API) still shows as selected
          options: ({..._thresholdOptions, state.thresholdMinutes}.toList()..sort()),
          selected: state.thresholdMinutes,
          optionLabel: (minutes) => '$minutes minutos',
          enabled: enabled && state.detectionEnabled,
          onSelect: viewModel.setThreshold,
        ),
        if (monitor != null)
          Padding(
            padding: routineSettingsRowPadding,
            child: _InactivityCounter(inactiveMinutes: monitor.inactiveMinutes),
          ),
      ],
    );
  }
}

/// "CONTADOR ACTUAL 03:18 minutos sin movimiento".
class _InactivityCounter extends StatelessWidget {
  final double inactiveMinutes;

  const new({required this.inactiveMinutes});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final totalSeconds = (inactiveMinutes * 60).round();
    final counter =
        '${(totalSeconds ~/ 60).toString().padLeft(2, '0')}:${(totalSeconds % 60).toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(GuardianRadius.subtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CONTADOR ACTUAL', style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
          Text(counter, style: routineMetricStyle.copyWith(color: colors.onSurface)),
          Text('minutos sin movimiento', style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final List<ActivityLogEntry> entries;

  const new({required this.entries});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return RoutineCard(
      children: [
        if (entries.isEmpty)
          Text(
            'Sin actividad registrada todavía.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        for (final (index, entry) in entries.indexed) ...[
          if (index > 0) Divider(color: colors.surfaceContainerHighest),
          _EventRow(entry: entry),
        ],
      ],
    );
  }
}

/// "Movimiento detectado · 13:42 · Contador reiniciado a cero".
class _EventRow extends StatelessWidget {
  final ActivityLogEntry entry;

  const new({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final time = formatClockTime(entry.occurredAt);
    final durationMinutes = entry.durationMinutes;
    final inactiveMinutes = entry.inactiveMinutes;

    final (title, detail, dot) = switch (entry.type) {
      ActivityLogEntryType.movementDetected => (
        'Movimiento detectado',
        '$time · Contador reiniciado a cero',
        colors.primary,
      ),
      ActivityLogEntryType.walkDetected => (
        'Caminata detectada',
        durationMinutes != null
            ? plural(
                durationMinutes,
                '$time · $durationMinutes minuto de actividad',
                '$time · $durationMinutes minutos de actividad',
              )
            : time,
        colors.primary,
      ),
      ActivityLogEntryType.prolongedInactivityDetected => (
        'Inactividad prolongada',
        inactiveMinutes != null ? '$time · ${inactiveMinutes.round()} minutos sin movimiento' : time,
        colors.tertiary,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: dot.withValues(alpha: 0.2), width: 4),
            ),
            child: DecoratedBox(decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall?.copyWith(color: colors.onSurface)),
                Text(detail, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
