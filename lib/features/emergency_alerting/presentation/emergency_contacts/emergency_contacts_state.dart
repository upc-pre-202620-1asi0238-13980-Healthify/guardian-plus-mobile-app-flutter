import 'package:flutter/foundation.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/emergency_contact.dart';

class EmergencyContactsState {
  const new({
    this.isLoading = false,
    this.errorMessage,
    this.contacts = const [],
    this.ackTimeoutSec = 60,
    this.careRecipientName = '',
    this.isSaving = false,
    this.isAdding = false,
    this.addErrorMessage,
    this.actionErrorMessage,
  });

  final bool isLoading;
  final String? errorMessage;
  // Active contacts in escalation order: the first one is the primary contact
  final List<EmergencyContact> contacts;
  final int ackTimeoutSec;
  final String careRecipientName;
  // A reorder or a removal is being saved; the list ignores further changes meanwhile
  final bool isSaving;
  final bool isAdding;
  // Shown inside the new-contact sheet, which covers the screen's snack bars
  final String? addErrorMessage;
  final String? actionErrorMessage;

  String get careRecipientFirstName => careRecipientName.split(' ').first;

  /// The platform keeps at least one active contact, so the last one cannot be removed.
  bool get canRemove => contacts.length > 1;

  // Nullable fields take a function, so copyWith can also set them back to null
  EmergencyContactsState copyWith({
    bool? isLoading,
    ValueGetter<String?>? errorMessage,
    List<EmergencyContact>? contacts,
    int? ackTimeoutSec,
    bool? isSaving,
    bool? isAdding,
    ValueGetter<String?>? addErrorMessage,
    ValueGetter<String?>? actionErrorMessage,
  }) {
    return EmergencyContactsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      contacts: contacts ?? this.contacts,
      ackTimeoutSec: ackTimeoutSec ?? this.ackTimeoutSec,
      careRecipientName: careRecipientName,
      isSaving: isSaving ?? this.isSaving,
      isAdding: isAdding ?? this.isAdding,
      addErrorMessage: addErrorMessage != null ? addErrorMessage() : this.addErrorMessage,
      actionErrorMessage: actionErrorMessage != null ? actionErrorMessage() : this.actionErrorMessage,
    );
  }
}
