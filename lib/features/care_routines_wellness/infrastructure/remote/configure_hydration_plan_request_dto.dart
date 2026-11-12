/// Same body as the platform's ConfigureHydrationPlanResource.
class ConfigureHydrationPlanRequestDto {
  final bool active;
  final int dailyGoalGlasses;
  final int intervalHours;
  final bool respectSleepWindow;

  const new({
    required this.active,
    required this.dailyGoalGlasses,
    required this.intervalHours,
    required this.respectSleepWindow,
  });

  Map<String, dynamic> toJson() {
    return {
      'active': active,
      'dailyGoalGlasses': dailyGoalGlasses,
      'intervalHours': intervalHours,
      'respectSleepWindow': respectSleepWindow,
    };
  }
}
