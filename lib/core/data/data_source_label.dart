/// Every time-sensitive value shown to a commuter carries one of these labels.
///
/// The app must never show [live] unless the value came from a genuine
/// real-time feed with a timestamp. Timetables are [scheduled]; tariff-based
/// fares are [estimate]; commuter reports are [community].
enum DataSourceKind { live, scheduled, estimate, official, community, unknown }

class SourcedValue<T> {
  const SourcedValue({
    required this.value,
    required this.kind,
    required this.source,
    required this.updatedAt,
  });

  final T value;
  final DataSourceKind kind;

  /// Human-readable origin, e.g. "MMRTA tariff, 1 Sep 2026".
  final String source;
  final DateTime updatedAt;

  /// Community reports go stale; callers decide the window per report type.
  bool isStale(Duration maxAge, {DateTime? now}) =>
      (now ?? DateTime.now()).difference(updatedAt) > maxAge;
}
