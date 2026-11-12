/// A time of day without date, e.g. 22:00 for the start of the sleep window.
class LocalTime {
  final int hour;
  final int minute;
  
  const new({required this.hour, required this.minute});
}