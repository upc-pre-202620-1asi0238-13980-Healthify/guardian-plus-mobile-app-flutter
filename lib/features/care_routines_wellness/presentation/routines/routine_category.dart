import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_status.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/sleep_classification.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_tone.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/routines_state.dart';

/// The seven routines of the "Todas las rutinas" list, in the order of the prototype.
enum RoutineCategory {
  medication(Icons.medication_outlined, 'Medicación', RoutineTone.mint),
  appointments(Icons.calendar_today_outlined, 'Citas médicas', RoutineTone.blue),
  activity(Icons.directions_walk, 'Actividad ligera', RoutineTone.mint),
  hydration(Icons.water_drop_outlined, 'Hidratación', RoutineTone.blue),
  sleep(Icons.bedtime_outlined, 'Sueño', RoutineTone.violet),
  inactivity(Icons.warning_amber_rounded, 'Inactividad', RoutineTone.orange),
  stock(Icons.layers_outlined, 'Stock de medicinas', RoutineTone.yellow);

  final IconData icon;
  final String title;
  final RoutineTone tone;

  const RoutineCategory(this.icon, this.title, this.tone);

  /// The routine screen a reminder of [type] belongs to, e.g. for the "Siguiente" card.
  static RoutineCategory of(ReminderType type) {
    return switch (type) {
      ReminderType.medication => medication,
      ReminderType.appointment => appointments,
      ReminderType.physicalActivity => activity,
      ReminderType.hydration => hydration,
    };
  }
}

/// Second line of a category card and its optional badge ("1 pendiente", "Fragmentado", "Reponer"…).
class RoutineCategorySummary {
  final String detail;
  final String? badge;
  final RoutineTone badgeTone;

  const new({required this.detail, this.badge, this.badgeTone = RoutineTone.mint});
}

extension RoutineCategorySummaries on RoutinesState {
  RoutineCategorySummary summaryOf(RoutineCategory category) {
    return switch (category) {
      RoutineCategory.medication => _medicationSummary(),
      RoutineCategory.appointments => RoutineCategorySummary(
        detail: nextAppointment != null
            ? 'Próxima: ${dayLabel(nextAppointment!.scheduledTime, now)}, '
                  '${formatClockTime(nextAppointment!.scheduledTime)}'
            : 'Sin citas próximas',
      ),
      RoutineCategory.activity => _activitySummary(),
      RoutineCategory.hydration => _hydrationSummary(),
      RoutineCategory.sleep => _sleepSummary(),
      RoutineCategory.inactivity => _inactivitySummary(),
      RoutineCategory.stock => _stockSummary(),
    };
  }

  RoutineCategorySummary _medicationSummary() {
    final count = countOf(ReminderType.medication);
    if (count.total == 0) return const RoutineCategorySummary(detail: 'Sin tomas hoy');
    return RoutineCategorySummary(
      detail: plural(count.total, '${count.total} toma hoy', '${count.total} tomas hoy'),
      badge: count.pending > 0
          ? plural(count.pending, '${count.pending} pendiente', '${count.pending} pendientes')
          : null,
      badgeTone: RoutineTone.yellow,
    );
  }

  RoutineCategorySummary _activitySummary() {
    final count = countOf(ReminderType.physicalActivity);
    if (count.total == 0) return const RoutineCategorySummary(detail: 'Sin actividades hoy');
    return RoutineCategorySummary(
      detail: '${count.completed} de ${count.total} completadas',
      badge: '${count.percentage}%',
    );
  }

  RoutineCategorySummary _hydrationSummary() {
    final plan = hydrationPlan;
    if (plan == null) return const RoutineCategorySummary(detail: 'Sin configurar');
    return RoutineCategorySummary(
      detail: hydrationIntervalLabel(plan.intervalHours),
      badge: plan.active ? 'Activa' : 'Pausada',
      badgeTone: plan.active ? RoutineTone.mint : RoutineTone.muted,
    );
  }

  RoutineCategorySummary _sleepSummary() {
    final sleep = lastSleep;
    if (sleep == null) return const RoutineCategorySummary(detail: 'Sin registros de sueño');
    final duration = formatSleepDuration(sleep.durationMinutes);
    final fragmented = sleep.classification == SleepClassification.fragmented;
    return RoutineCategorySummary(
      detail: isSameDay(sleep.endTime, now) ? '$duration anoche' : '$duration el ${formatDayAndMonth(sleep.endTime)}',
      badge: fragmented ? 'Fragmentado' : 'Regular',
      badgeTone: fragmented ? RoutineTone.orange : RoutineTone.mint,
    );
  }

  RoutineCategorySummary _inactivitySummary() {
    final monitor = activityMonitor;
    if (monitor == null) return const RoutineCategorySummary(detail: 'Sin datos de la pulsera');
    final inactiveSince = monitor.inactivitySince;
    // The only case worth a badge: the person has not moved for longer than the threshold
    if (monitor.status == ActivityStatus.inactivityDetected && inactiveSince != null) {
      return RoutineCategorySummary(
        detail: 'Sin movimiento desde las ${formatClockTime(inactiveSince)}',
        badge: 'Inactividad',
        badgeTone: RoutineTone.orange,
      );
    }
    return RoutineCategorySummary(
      detail: monitor.detectionEnabled ? 'Vigilancia diurna activa' : 'Vigilancia desactivada',
    );
  }

  RoutineCategorySummary _stockSummary() {
    final stock = lowestStock;
    if (stock == null) return const RoutineCategorySummary(detail: 'Sin medicamentos registrados');
    final days = stock.remainingDaysOfSupply.toInt();
    return RoutineCategorySummary(
      detail: plural(days, '${stock.medicationName} para $days día', '${stock.medicationName} para $days días'),
      badge: medicationStocks.any((stock) => stock.restockRecommended) ? 'Reponer' : null,
      badgeTone: RoutineTone.orange,
    );
  }
}
