import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_status.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/appointments/appointments_state.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/appointments/appointments_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_card.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_tone.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_top_bar.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/navigation/care_routines_wellness_navigation.dart';

class AppointmentsPage extends StatefulWidget {
  final AppointmentsViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late final AppointmentsViewModel _viewModel = widget.viewModel;
  String? _expandedId;

  @override
  void dispose() {
    // The page owns its view model: every visit starts with a fresh one (registerFactory)
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openForm() async {
    final message = await openAppointmentForm(context);
    if (message != null) _viewModel.onFormResult(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoutineTopBar(
        title: 'Citas médicas',
        subtitle: 'Controles y consultas',
        onBackPressed: () => Navigator.pop(context),
        action: RoutineTopBarButton(icon: Icons.add, tooltip: 'Nueva cita', onPressed: _openForm),
      ),
      body: RoutineMessageEffect(
        source: _viewModel,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            final state = _viewModel.state;
            return switch (state) {
              AppointmentsState(isLoaded: false, errorMessage: null) => const RoutineLoadingState(),
              AppointmentsState(isLoaded: false) => RoutineErrorState(
                message: state.errorMessage ?? '',
                onRetry: _viewModel.load,
              ),
              _ => _buildList(state),
            };
          },
        ),
      ),
    );
  }

  Widget _buildList(AppointmentsState state) {
    final next = state.nextAppointment;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        if (next == null)
          RoutineEmptyState(
            icon: Icons.calendar_today_outlined,
            title: 'Sin citas próximas',
            message: 'Agenda un control para que ${_viewModel.careRecipientFirstName} reciba el aviso a tiempo.',
            actionLabel: 'Agendar cita',
            onAction: _openForm,
          )
        else
          _NextAppointmentCard(
            key: ValueKey('next-${next.id}'),
            appointment: next,
            now: state.now,
            isCancelling: state.cancellingId == next.id,
            onCancel: () => _viewModel.cancelAppointment(next),
          ),
        if (state.laterAppointments.isNotEmpty) ...[
          const SizedBox(height: 10),
          const RoutineSectionTitle(text: 'Próximas'),
          for (final appointment in state.laterAppointments) ...[
            const SizedBox(height: 10),
            _LaterAppointmentCard(
              key: ValueKey(appointment.id),
              appointment: appointment,
              expanded: _expandedId == appointment.id,
              isCancelling: state.cancellingId == appointment.id,
              onTap: () => setState(() => _expandedId = _expandedId == appointment.id ? null : appointment.id),
              onCancel: () => _viewModel.cancelAppointment(appointment),
            ),
          ],
        ],
      ],
    );
  }
}

/// Highlighted card of the next appointment: date tile, day and state badges, time, notice and place.
class _NextAppointmentCard extends StatelessWidget {
  final Reminder appointment;
  final DateTime now;
  final bool isCancelling;
  final VoidCallback onCancel;

  const new({
    super.key,
    required this.appointment,
    required this.now,
    required this.isCancelling,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final day = dayLabel(appointment.scheduledTime, now);
    final location = appointment.location;
    final instructions = appointment.instructions;

    return RoutineCard(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateTile(at: appointment.scheduledTime, size: 58, dayFontSize: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      RoutineBadge(text: day[0].toUpperCase() + day.substring(1), tone: RoutineTone.yellow),
                      _AppointmentStatusBadge(appointment: appointment),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      appointment.displayTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.onSurface),
                    ),
                  ),
                  _DetailLine(
                    icon: Icons.schedule,
                    text: '${formatClockTime(appointment.scheduledTime)} · '
                        '${leadTimeLabel(appointment.leadTimeMinutes)}',
                  ),
                  if (location != null) _DetailLine(icon: Icons.place_outlined, text: location),
                  if (instructions != null) _DetailLine(icon: Icons.info_outline, text: instructions),
                ],
              ),
            ),
          ],
        ),
        _CancelButton(isCancelling: isCancelling, onPressed: onCancel),
      ],
    );
  }
}

/// Collapsed row of a later appointment; tapping it shows the notice and a way to cancel it.
class _LaterAppointmentCard extends StatelessWidget {
  final Reminder appointment;
  final bool expanded;
  final bool isCancelling;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const new({
    super.key,
    required this.appointment,
    required this.expanded,
    required this.isCancelling,
    required this.onTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(GuardianRadius.medium);
    final instructions = appointment.instructions;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: colors.outline)),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _DateTile(at: appointment.scheduledTime, size: 46, dayFontSize: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appointment.displayTitle, style: text.titleSmall?.copyWith(color: colors.onSurface)),
                        Text(
                          [formatClockTime(appointment.scheduledTime), ?appointment.location].join(' · '),
                          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(Icons.chevron_right, size: 18, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
              if (expanded) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 11, bottom: 10),
                  child: Divider(color: colors.surfaceContainerHighest),
                ),
                _DetailLine(icon: Icons.notifications_none, text: leadTimeLabel(appointment.leadTimeMinutes)),
                if (instructions != null) _DetailLine(icon: Icons.info_outline, text: instructions),
                _CancelButton(isCancelling: isCancelling, onPressed: onCancel),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentStatusBadge extends StatelessWidget {
  final Reminder appointment;

  const new({required this.appointment});

  @override
  Widget build(BuildContext context) {
    if (appointment.status == ReminderStatus.scheduled) return const RoutineBadge(text: 'Agendada');
    return const RoutineBadge(text: 'Aviso enviado', tone: RoutineTone.blue);
  }
}

class _CancelButton extends StatelessWidget {
  final bool isCancelling;
  final VoidCallback onPressed;

  const new({required this.isCancelling, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextButton(
        onPressed: isCancelling ? null : onPressed,
        child: isCancelling
            ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : Text('Cancelar cita', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ),
    );
  }
}

/// Mint square with the day number and the month, e.g. "24 ABR".
class _DateTile extends StatelessWidget {
  final DateTime at;
  final double size;
  final double dayFontSize;

  const new({required this.at, required this.size, required this.dayFontSize});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      width: size,
      height: size + 2,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            at.toLocal().day.toString().padLeft(2, '0'),
            style: text.titleLarge?.copyWith(
              fontFamily: GuardianFonts.data,
              fontWeight: FontWeight.w700,
              fontSize: dayFontSize,
              color: colors.primary,
            ),
          ),
          Text(formatShortMonth(at), style: text.labelSmall?.copyWith(fontSize: 9, color: colors.primary)),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const new({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 15, color: colors.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
