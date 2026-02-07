import 'package:flutter_test/flutter_test.dart';
import 'package:period_tracker_flutter/features/cycle/domain/entities/cycle_entry.dart';
import 'package:period_tracker_flutter/features/cycle/domain/services/cycle_analytics_engine.dart';

void main() {
  const CycleAnalyticsEngine engine = CycleAnalyticsEngine();

  List<CycleEntry> regularEntries() {
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
      CycleEntry(
        id: '4',
        startDate: DateTime(2025, 3, 26),
        endDate: DateTime(2025, 3, 30),
      ),
    ];
  }

  group('CycleAnalyticsEngine', () {
    test('weightedAverageCycleLength returns default for empty values', () {
      final double value = engine.weightedAverageCycleLength(<int>[]);
      expect(value, 28);
    });

    test('weightedAverageCycleLength emphasizes recent cycles', () {
      final double value = engine.weightedAverageCycleLength(<int>[24, 28, 32]);
      expect(value, greaterThan(28));
      expect(value, closeTo(29.33, 0.05));
    });

    test('calculateCycleLengths filters invalid lengths', () {
      final List<CycleEntry> entries = <CycleEntry>[
        CycleEntry(
          id: '1',
          startDate: DateTime(2025, 1, 1),
          endDate: DateTime(2025, 1, 4),
        ),
        CycleEntry(
          id: '2',
          startDate: DateTime(2025, 1, 4),
          endDate: DateTime(2025, 1, 7),
        ),
        CycleEntry(
          id: '3',
          startDate: DateTime(2025, 2, 7),
          endDate: DateTime(2025, 2, 11),
        ),
      ];

      final List<int> lengths = engine.calculateCycleLengths(entries);
      expect(lengths.length, 1);
      expect(lengths.first, 34);
    });

    test('buildAnalytics detects regular cycles', () {
      final analytics = engine.buildAnalytics(regularEntries());
      expect(analytics.isIrregular, isFalse);
      expect(analytics.standardDeviation, lessThan(3));
    });

    test('buildAnalytics detects irregular cycles', () {
      final List<CycleEntry> irregularEntries = <CycleEntry>[
        CycleEntry(
          id: '1',
          startDate: DateTime(2025, 1, 1),
          endDate: DateTime(2025, 1, 5),
        ),
        CycleEntry(
          id: '2',
          startDate: DateTime(2025, 1, 19),
          endDate: DateTime(2025, 1, 24),
        ),
        CycleEntry(
          id: '3',
          startDate: DateTime(2025, 2, 23),
          endDate: DateTime(2025, 2, 28),
        ),
        CycleEntry(
          id: '4',
          startDate: DateTime(2025, 3, 17),
          endDate: DateTime(2025, 3, 21),
        ),
      ];

      final analytics = engine.buildAnalytics(irregularEntries);
      expect(analytics.standardDeviation, greaterThanOrEqualTo(3));
      expect(analytics.isIrregular, isTrue);
    });

    test('predictNextCycle returns null for empty entries', () {
      final prediction = engine.predictNextCycle(<CycleEntry>[]);
      expect(prediction, isNull);
    });

    test('predictNextCycle computes ovulation and fertile window', () {
      final prediction = engine.predictNextCycle(regularEntries());
      expect(prediction, isNotNull);

      final DateTime expectedOvulation = prediction!.predictedStartDate
          .subtract(const Duration(days: 14));
      expect(prediction.ovulationDate, expectedOvulation);

      expect(
        prediction.fertileWindowStart,
        prediction.ovulationDate.subtract(const Duration(days: 5)),
      );
      expect(
        prediction.fertileWindowEnd,
        prediction.ovulationDate.add(const Duration(days: 1)),
      );
    });

    test('confidence is bounded', () {
      final prediction = engine.predictNextCycle(regularEntries());
      expect(prediction, isNotNull);
      expect(prediction!.confidence, inInclusiveRange(0.35, 0.98));
    });
  });
}
