import 'package:flutter_test/flutter_test.dart';
import 'package:period_tracker_flutter/features/cycle/domain/entities/cycle_entry.dart';
import 'package:period_tracker_flutter/features/cycle/domain/services/cycle_analytics_engine.dart';

void main() {
  const CycleAnalyticsEngine engine = CycleAnalyticsEngine();

  List<CycleEntry> sampleEntries() {
    return <CycleEntry>[
      CycleEntry(
        id: '1',
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 5),
      ),
      CycleEntry(
        id: '2',
        startDate: DateTime(2025, 1, 29),
        endDate: DateTime(2025, 2, 2),
      ),
      CycleEntry(
        id: '3',
        startDate: DateTime(2025, 2, 26),
        endDate: DateTime(2025, 3, 2),
      ),
    ];
  }

  test('weighted average uses recency weighting', () {
    final double weighted = engine.weightedAverageCycleLength(<int>[
      26,
      30,
      28,
    ]);
    expect(weighted, closeTo(28.33, 0.1));
  });

  test('prediction returns next cycle with confidence', () {
    final prediction = engine.predictNextCycle(sampleEntries());
    expect(prediction, isNotNull);
    expect(prediction!.weightedAverageCycleLength, greaterThan(0));
    expect(prediction.confidence, inInclusiveRange(0.35, 0.98));
  });

  test('irregularity detection uses standard deviation threshold', () {
    final List<CycleEntry> irregular = <CycleEntry>[
      CycleEntry(
        id: '1',
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 5),
      ),
      CycleEntry(
        id: '2',
        startDate: DateTime(2025, 1, 20),
        endDate: DateTime(2025, 1, 24),
      ),
      CycleEntry(
        id: '3',
        startDate: DateTime(2025, 2, 22),
        endDate: DateTime(2025, 2, 26),
      ),
      CycleEntry(
        id: '4',
        startDate: DateTime(2025, 3, 16),
        endDate: DateTime(2025, 3, 20),
      ),
    ];

    final analytics = engine.buildAnalytics(irregular);
    expect(analytics.standardDeviation, greaterThan(0));
    expect(analytics.isIrregular, isTrue);
  });
}
