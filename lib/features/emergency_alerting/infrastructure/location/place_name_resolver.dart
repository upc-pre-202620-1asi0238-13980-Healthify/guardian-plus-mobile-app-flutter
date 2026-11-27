/// Turns the coordinates sent by the wristband into a place a family member recognizes ("Av. Larco 345 · Miraflores").
abstract class PlaceNameResolver {
  /// The place name, or null when it cannot be resolved.
  Future<String?> nameOf(double latitude, double longitude);
}
