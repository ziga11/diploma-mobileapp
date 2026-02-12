enum RequestTimeline {
  threeMonths(3),
  sixMonths(6),
  nineMonths(9);

  final int value;
  const RequestTimeline(this.value);

  String label(Map<String, String> t) => "$value ${t["months"]}";
}
