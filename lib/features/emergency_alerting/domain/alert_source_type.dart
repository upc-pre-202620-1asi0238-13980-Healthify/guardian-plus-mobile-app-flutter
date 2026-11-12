/// What raised the alert: the wristband (fall, SOS) or another bounded context.
enum AlertSourceType {
  fallDetected,
  sosTriggered,
  vitalSignAnomaly,
  safeZoneViolation,
  prolongedInactivity,
  reminderReissued,
  medicationRestockSuggested,
}
