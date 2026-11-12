import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/network/api_exception.dart';

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
            OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

/// The message of a failed request (the platform's own when it gave one), or [fallback] for anything else,
/// such as an answer the app cannot read.
String errorMessageOf(Object error, String fallback) {
  return error is ApiException ? error.message : fallback;
}
