import 'package:guardian_plus_app/core/session/care_context.dart';

/// The demo family of the platform's seed data: María Rojas (contact 1) caring for her mother Elena.
///
/// It stands in for the sign-in until the IAM and Profile features exist in this app; then the sign-in saves
/// the real care context and this file goes away.
const demoCareContext = CareContext(
  userAccountId: '1b3fdfe0-326f-4f36-80eb-b4d007cf4d19',
  userFullName: 'María Rojas',
  careRecipientProfileId: '6b0b1a3e-5f5e-4d6e-9a59-3c1c1f6c2b10',
  careRecipientName: 'Elena Rojas',
);
