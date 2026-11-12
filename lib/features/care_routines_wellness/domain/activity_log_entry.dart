/// A noteworthy activity fact: movement after a still period, a finished walk or an inactivity detection.
class ActivityLogEntry {
  final String id;
  final ActivityLogEntryType type;
  // Start of the walk, for walks
  final DateTime occurredAt;
  final int? durationMinutes;
  final int? steps;
  // Minutes the person had been still, for movement and inactivity entries
  final double? inactiveMinutes;

  const new({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.durationMinutes,
    required this.steps,
    required this.inactiveMinutes,
  });
}

enum ActivityLogEntryType { movementDetected, walkDetected, prolongedInactivityDetected }