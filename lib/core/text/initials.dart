/// "María Rojas" → "MR".
String initialsOf(String name) {
  return name
      .split(' ')
      .where((word) => word.trim().isNotEmpty)
      .take(2)
      // By rune, so a name that starts with an accented letter keeps it whole
      .map((word) => String.fromCharCode(word.runes.first).toUpperCase())
      .join();
}
