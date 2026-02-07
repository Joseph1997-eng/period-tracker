import 'dart:math' as math;

import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/cycle_entry.dart';
import '../../domain/entities/cycle_prediction.dart';

class CycleAnalyticsEngine {
  const CycleAnalyticsEngine();

  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;
  static const int minValidCycleLength = 15;
  static const int maxValidCycleLength = 60;
  static const double irregularityStdDevThreshold = 3.0;

  List<int> calculateCycleLengths(List<CycleEntry> entries) {
    if (entries.length < 2) {
      return <int>[];
    }

    final List<CycleEntry> sorted = List<CycleEntry>.from(
      entries,
    )..sort((CycleEntry a, CycleEntry b) => a.startDate.compareTo(b.startDate));

    final List<int> lengths = <int>[];
    for (int i = 1; i < sorted.length; i++) {
      final int days = _dateOnly(
        sorted[i].startDate,
      ).difference(_dateOnly(sorted[i - 1].startDate)).inDays;

      if (days >= minValidCycleLength && days <= maxValidCycleLength) {
        lengths.add(days);
      }
    }

    return lengths;
  }

  double weightedAverageCycleLength(List<int> cycleLengths) {
    if (cycleLengths.isEmpty) {
      return defaultCycleLength.toDouble();
    }

    double weightedSum = 0;
    double weightSum = 0;

    for (int i = 0; i < cycleLengths.length; i++) {
      final double weight = i + 1;
      weightedSum += cycleLengths[i] * weight;
      weightSum += weight;
    }

    return weightedSum / weightSum;
  }

  double mean(List<int> values) {
    if (values.isEmpty) {
      return defaultCycleLength.toDouble();
    }

    final int sum = values.fold<int>(0, (int prev, int item) => prev + item);
    return sum / values.length;
  }

  double standardDeviation(List<int> values) {
    if (values.length < 2) {
      return 0;
    }

    final double avg = mean(values);
    final double variance =
        values
            .map<double>((int value) => (value - avg) * (value - avg))
            .fold<double>(0, (double prev, double item) => prev + item) /
        values.length;

    return math.sqrt(variance);
  }

  AnalyticsSummary buildAnalytics(List<CycleEntry> entries) {
    final List<int> cycleLengths = calculateCycleLengths(entries);
    final double average = mean(cycleLengths);
    final double weightedAverage = weightedAverageCycleLength(cycleLengths);
    final double stdDev = standardDeviation(cycleLengths);

    return AnalyticsSummary(
      cycleLengths: cycleLengths,
      averageCycleLength: average,
      weightedAverageCycleLength: weightedAverage,
      standardDeviation: stdDev,
      isIrregular: stdDev >= irregularityStdDevThreshold,
    );
  }

  CyclePrediction? predictNextCycle(List<CycleEntry> entries) {
    if (entries.isEmpty) {
      return null;
    }

    final List<CycleEntry> sorted = List<CycleEntry>.from(
      entries,
    )..sort((CycleEntry a, CycleEntry b) => a.startDate.compareTo(b.startDate));

    final CycleEntry latest = sorted.last;
    final List<int> cycleLengths = calculateCycleLengths(sorted);

    final double weightedAverage = weightedAverageCycleLength(cycleLengths);
    final int predictedCycleLength = weightedAverage.round().clamp(
      minValidCycleLength,
      maxValidCycleLength,
    );

    final int averagePeriodLength = _averagePeriodLength(sorted);

    final DateTime nextPeriodStart = _dateOnly(
      latest.startDate,
    ).add(Duration(days: predictedCycleLength));
    final DateTime nextPeriodEnd = nextPeriodStart.add(
      Duration(days: averagePeriodLength - 1),
    );

    final DateTime ovulationDate = nextPeriodStart.subtract(
      const Duration(days: 14),
    );
    final DateTime fertileWindowStart = ovulationDate.subtract(
      const Duration(days: 5),
    );
    final DateTime fertileWindowEnd = ovulationDate.add(
      const Duration(days: 1),
    );

    final double confidence = _calculateConfidence(cycleLengths);

    return CyclePrediction(
      predictedStartDate: nextPeriodStart,
      predictedEndDate: nextPeriodEnd,
      ovulationDate: ovulationDate,
      fertileWindowStart: fertileWindowStart,
      fertileWindowEnd: fertileWindowEnd,
      weightedAverageCycleLength: weightedAverage,
      confidence: confidence,
    );
  }

  int _averagePeriodLength(List<CycleEntry> entries) {
    if (entries.isEmpty) {
      return defaultPeriodLength;
    }

    final int totalPeriodDays = entries.fold<int>(
      0,
      (int prev, CycleEntry item) => prev + item.periodLengthDays,
    );

    return (totalPeriodDays / entries.length).round().clamp(2, 10);
  }

  double _calculateConfidence(List<int> cycleLengths) {
    if (cycleLengths.length < 2) {
      return 0.45;
    }

    final double stdDev = standardDeviation(cycleLengths);
    return (1 - (stdDev / 10)).clamp(0.35, 0.98);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
