enum SessionDuration {
  twoMinutes(Duration(minutes: 2)),
  fiveMinutes(Duration(minutes: 5)),
  tenMinutes(Duration(minutes: 10)),
  fifteenMinutes(Duration(minutes: 15));

  final Duration value;

  const SessionDuration(this.value);
}
