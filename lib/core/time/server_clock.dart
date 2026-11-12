/// The platform's clock as seen from the phone. Escalation deadlines are decided on the server, so countdowns
/// use its time: a phone clock that is 30 s off would show 1:30 left for a 60 s timeout.
/// The offset is learned from the Date header of every response (see ApiClient).
class ServerClock {
  Duration _offset = Duration.zero;

  DateTime now() => DateTime.now().add(_offset);

  void sync(DateTime serverDate) {
    _offset = serverDate.difference(DateTime.now());
  }
}
