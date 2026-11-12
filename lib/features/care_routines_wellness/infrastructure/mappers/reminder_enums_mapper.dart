import 'package:guardian_plus_app/features/care_routines_wellness/domain/recurrence_frequency.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_status.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/reminder_type.dart';

/// The platform names the reminder types in upper snake case (MEDICATION, PHYSICAL_ACTIVITY, ...).
extension ReminderTypeMapper on ReminderType {
  String toApi() {
    return switch (this) {
      ReminderType.medication => 'MEDICATION',
      ReminderType.appointment => 'APPOINTMENT',
      ReminderType.physicalActivity => 'PHYSICAL_ACTIVITY',
      ReminderType.hydration => 'HYDRATION',
    };
  }

  static ReminderType fromApi(String value) {
    return ReminderType.values.firstWhere(
      (type) => type.toApi() == value,
      orElse: () => throw FormatException('Unknown reminder type: $value'),
    );
  }
}

extension ReminderStatusMapper on ReminderStatus {
  String toApi() {
    return switch (this) {
      ReminderStatus.scheduled => 'SCHEDULED',
      ReminderStatus.issued => 'ISSUED',
      ReminderStatus.confirmed => 'CONFIRMED',
      ReminderStatus.cancelled => 'CANCELLED',
      ReminderStatus.reissued => 'REISSUED',
      ReminderStatus.suppressed => 'SUPPRESSED',
      ReminderStatus.missed => 'MISSED',
    };
  }

  static ReminderStatus fromApi(String value) {
    return ReminderStatus.values.firstWhere(
      (status) => status.toApi() == value,
      orElse: () => throw FormatException('Unknown reminder status: $value'),
    );
  }
}

extension RecurrenceFrequencyMapper on RecurrenceFrequency {
  String toApi() {
    return switch (this) {
      RecurrenceFrequency.once => 'ONCE',
      RecurrenceFrequency.daily => 'DAILY',
      RecurrenceFrequency.weekly => 'WEEKLY',
    };
  }
}

/// Days go from DateTime.monday (1) to DateTime.sunday (7), the same order as the platform's DayOfWeek.
abstract final class DayOfWeekMapper {
  static const _names = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];

  static String toApi(int dayOfWeek) => _names[dayOfWeek - 1];
}
