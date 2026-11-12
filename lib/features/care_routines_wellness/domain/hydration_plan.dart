import 'package:guardian_plus_app/features/care_routines_wellness/domain/local_time.dart';

/// Daily water goal and reminder interval, with today's progress.
class HydrationPlan {
  final bool active;
  final int dailyGoalGlasses;
  final int intervalHours;
  final bool respectSleepWindow;
  final LocalTime? sleepWindowStart;
  final LocalTime? sleepWindowEnd;
  final int glassesConsumedToday;
  final int remainingGlassesToday;
  final DateTime? nextReminderAt;

  const new({
    required this.active,
    required this.dailyGoalGlasses,
    required this.intervalHours,
    required this.respectSleepWindow,
    required this.sleepWindowStart,
    required this.sleepWindowEnd,
    required this.glassesConsumedToday,
    required this.remainingGlassesToday,
    required this.nextReminderAt,
  });

  bool get goalReached => glassesConsumedToday >= dailyGoalGlasses;

  int get progressPercentage {
    if (dailyGoalGlasses == 0) return 0;
    return (glassesConsumedToday * 100 ~/ dailyGoalGlasses).clamp(0, 100);
  }
}