/// A hydration plan as the platform sends it (HydrationPlanResource); times of day as "22:00" or "22:00:00".
class HydrationPlanDto {
  final String id;
  final String personUnderCareId;
  final bool active;
  final int dailyGoalGlasses;
  final int intervalHours;
  final bool respectSleepWindow;
  final String? sleepWindowStart;
  final String? sleepWindowEnd;
  final int glassesConsumedToday;
  final int remainingGlassesToday;
  final String? nextReminderAt;

  const new({
    required this.id,
    required this.personUnderCareId,
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

  factory HydrationPlanDto.fromJson(Map<String, dynamic> json) {
    return HydrationPlanDto(
      id: json['id'],
      personUnderCareId: json['personUnderCareId'],
      active: json['active'],
      dailyGoalGlasses: json['dailyGoalGlasses'],
      intervalHours: json['intervalHours'],
      respectSleepWindow: json['respectSleepWindow'],
      sleepWindowStart: json['sleepWindowStart'],
      sleepWindowEnd: json['sleepWindowEnd'],
      glassesConsumedToday: json['glassesConsumedToday'],
      remainingGlassesToday: json['remainingGlassesToday'],
      nextReminderAt: json['nextReminderAt'],
    );
  }
}
