import 'package:flutter/material.dart';

/// A view model with one-off messages, the app's version of the prototype's toast: a confirmation written by
/// the app ("Dosis registrada como administrada") or the platform's own reason for rejecting an action.
abstract interface class RoutineMessageSource implements Listenable {
  String? get message;

  void onMessageShown();
}

/// Shows each message of [source] once in a snack bar and tells it the message was shown.
class RoutineMessageEffect extends StatefulWidget {
  final RoutineMessageSource source;
  final Widget child;

  const new({super.key, required this.source, required this.child});

  @override
  State<RoutineMessageEffect> createState() => _RoutineMessageEffectState();
}

class _RoutineMessageEffectState extends State<RoutineMessageEffect> {
  @override
  void initState() {
    super.initState();
    widget.source.addListener(_showMessage);
  }

  @override
  void dispose() {
    widget.source.removeListener(_showMessage);
    super.dispose();
  }

  void _showMessage() {
    final message = widget.source.message;
    if (message == null || !mounted) return;
    widget.source.onMessageShown();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
