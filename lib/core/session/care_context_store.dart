import 'package:guardian_plus_app/core/session/care_context.dart';

/// Keeps the [CareContext] of the signed-in account for the screens behind the sign-in. The sign-in flow saves
/// it and the sign-out clears it.
class CareContextStore {
  CareContext? _current;

  /// The care context, or null before it is loaded (no session yet).
  CareContext? get current => _current;

  /// The care context of the screens behind the sign-in. They are only reachable once it is loaded, so its
  /// absence is a navigation bug, not a user error.
  CareContext require() {
    final careContext = _current;
    if (careContext == null) {
      throw StateError('The care context is not loaded');
    }
    return careContext;
  }

  void save(CareContext careContext) {
    _current = careContext;
  }

  /// Updates the number the "call" buttons dial, e.g. after the emergency contacts change.
  void updateCallNumber(String? callNumber) {
    final careContext = _current;
    if (careContext == null) return;
    _current = careContext.copyWith(callNumber: () => callNumber);
  }

  void clear() {
    _current = null;
  }
}
