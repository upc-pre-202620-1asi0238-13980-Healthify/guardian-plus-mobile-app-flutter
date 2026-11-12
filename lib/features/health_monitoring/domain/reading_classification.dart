enum ReadingClassification {
  belowRange,
  withinRange,
  aboveRange;

  bool get isOutRange => this != ReadingClassification.withinRange;
}
