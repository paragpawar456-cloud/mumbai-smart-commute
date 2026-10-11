import 'package:flutter_test/flutter_test.dart';
import 'package:mumbai_smart_commute/core/data/data_source_label.dart';

void main() {
  test('community report goes stale after its window', () {
    final now = DateTime(2026, 10, 11, 9);
    final report = SourcedValue(
      value: 'Long auto queue',
      kind: DataSourceKind.community,
      source: 'Commuter report',
      updatedAt: now.subtract(const Duration(minutes: 31)),
    );
    expect(report.isStale(const Duration(minutes: 30), now: now), isTrue);
    expect(report.isStale(const Duration(minutes: 45), now: now), isFalse);
  });
}
