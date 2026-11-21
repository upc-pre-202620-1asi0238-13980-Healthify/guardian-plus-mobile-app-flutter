import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/l10n/app_localizations.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

/// Shown while a screen loads its data for the first time.
class LoadingView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Shown when a screen could not load its data, with a way to try again.
class ErrorRetryView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const new({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: Text(context.l10n.commonRetry)),
          ],
        ),
      ),
    );
  }
}

/// What a screen was doing when it failed, so it can say so in the user's language.
enum FailedTask {
  loadAlerts,
  loadAlert,
  loadHistory,
  loadSettings,
  loadContacts,
  acknowledge,
  runAction,
  changeChannel,
  keepOneChannel,
  saveSettings,
  reorderContacts,
  removeContact,
  addContact;

  String message(AppLocalizations l10n) => switch (this) {
    FailedTask.loadAlerts => l10n.errorLoadAlerts,
    FailedTask.loadAlert => l10n.errorLoadAlert,
    FailedTask.loadHistory => l10n.errorLoadHistory,
    FailedTask.loadSettings => l10n.errorLoadSettings,
    FailedTask.loadContacts => l10n.errorLoadContacts,
    FailedTask.acknowledge => l10n.errorAcknowledge,
    FailedTask.runAction => l10n.errorRunAction,
    FailedTask.changeChannel => l10n.errorChangeChannel,
    FailedTask.keepOneChannel => l10n.errorKeepOneChannel,
    FailedTask.saveSettings => l10n.errorSaveSettings,
    FailedTask.reorderContacts => l10n.errorReorderContacts,
    FailedTask.removeContact => l10n.errorRemoveContact,
    FailedTask.addContact => l10n.errorAddContact,
  };
}

/// A failure the screen reports: the platform's own message when it gave one, or what it was doing for anything
/// else, such as an answer the app cannot read.
class ScreenError {
  final FailedTask task;
  final String? platformMessage;

  const new(this.task, {this.platformMessage});

  factory ScreenError.of(Object error, FailedTask task) {
    return ScreenError(task, platformMessage: error is ApiException ? error.message : null);
  }

  String message(AppLocalizations l10n) => platformMessage ?? task.message(l10n);
}
