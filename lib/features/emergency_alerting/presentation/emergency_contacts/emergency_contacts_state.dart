import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/screen_states.dart';

class EmergencyContactsState {
  const new({
    this.isLoading = false,
    this.error,
    this.contacts = const [],
    this.ackTimeoutSec = 60,
    this.careRecipientName = '',
    this.isSaving = false,
    this.isAdding = false,
    this.addError,
    this.actionError,
  });

  final bool isLoading;
  final ScreenError? error;
  // Active contacts in escalation order: the first one is the primary contact
  final List<EmergencyContact> contacts;
  final int ackTimeoutSec;
  final String careRecipientName;
  // A reorder or a removal is being saved; the list ignores further changes meanwhile
  final bool isSaving;
  final bool isAdding;
  // Shown inside the new-contact sheet, which covers the screen's snack bars
  final ScreenError? addError;
  final ScreenError? actionError;

  String get careRecipientFirstName => careRecipientName.split(' ').first;

  /// The platform keeps at least one active contact, so the last one cannot be removed.
  bool get canRemove => contacts.length > 1;

  // Nullable fields take a function, so copyWith can also set them back to null
  EmergencyContactsState copyWith({
    bool? isLoading,
    ValueGetter<ScreenError?>? error,
    List<EmergencyContact>? contacts,
    int? ackTimeoutSec,
    bool? isSaving,
    bool? isAdding,
    ValueGetter<ScreenError?>? addError,
    ValueGetter<ScreenError?>? actionError,
  }) {
    return EmergencyContactsState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      contacts: contacts ?? this.contacts,
      ackTimeoutSec: ackTimeoutSec ?? this.ackTimeoutSec,
      careRecipientName: careRecipientName,
      isSaving: isSaving ?? this.isSaving,
      isAdding: isAdding ?? this.isAdding,
      addError: addError != null ? addError() : this.addError,
      actionError: actionError != null ? actionError() : this.actionError,
    );
  }
}
