import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// Spinner of the very first load; refreshes keep the old data on screen.
class RoutineLoadingState extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Why the screen could not load, with a way to try again.
class RoutineErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const new({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(GuardianRadius.medium),
            border: Border.all(color: colors.outline),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurface),
              ),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round mint icon, title, explanation and an optional action, e.g. "Sin citas próximas".
class RoutineEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const new({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: colors.primaryContainer,
            child: Icon(icon, size: 24, color: colors.primary),
          ),
          const SizedBox(height: 10),
          Text(title, style: text.titleMedium?.copyWith(color: colors.onSurface)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 10),
            FilledButton.tonal(
              onPressed: onAction,
              style: FilledButton.styleFrom(minimumSize: const Size(0, 40), shape: const StadiumBorder()),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// The message of a failed request (the platform's own when it gave one), or [fallback] for anything else,
/// such as an answer the app cannot read.
String routineErrorMessage(Object error, String fallback) {
  return error is ApiException ? error.message : fallback;
}

/// A section that is not essential to the screen: when it fails, it stays empty instead of failing the rest.
/// The error is caught right away, so a section that fails before it is awaited is not reported as unhandled.
Future<T?> orNullOnError<T>(Future<T> future) {
  return future.then<T?>((value) => value, onError: (Object _) => null);
}
