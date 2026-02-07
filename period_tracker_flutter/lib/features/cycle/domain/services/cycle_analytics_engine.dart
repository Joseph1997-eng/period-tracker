import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/cycle_entry.dart';
import '../../domain/entities/cycle_prediction.dart';

class CycleAnalyticsEngine {
  const CycleAnalyticsEngine();

  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;
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
      if (days >= 15 && days <= 60) {
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

    final int sum = values.fold<int>(
      0,
      (int previous, int value) => previous + value,
    );
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
            .fold<double>(
              0,
              (double previous, double value) => previous + value,
            ) /
        values.length;

    return variance.sqrt();
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
    final int predictedCycleLength = weightedAverage.round();

    final int averagePeriodLength = _averagePeriodLength(sorted);
    final DateTime nextStart = _dateOnly(
      latest.startDate,
    ).add(Duration(days: predictedCycleLength));
    final DateTime nextEnd = nextStart.add(
      Duration(days: averagePeriodLength - 1),
    );

    final DateTime ovulationDate = nextStart.subtract(const Duration(days: 14));
    final DateTime fertileWindowStart = ovulationDate.subtract(
      const Duration(days: 5),
    );
    final DateTime fertileWindowEnd = ovulationDate.add(
      const Duration(days: 1),
    );

    final double confidence = _calculateConfidence(cycleLengths);

    return CyclePrediction(
      predictedStartDate: nextStart,
      predictedEndDate: nextEnd,
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
      (int previous, CycleEntry entry) => previous + entry.periodLengthDays,
    );

    final int average = (totalPeriodDays / entries.length).round();
    return average.clamp(2, 10);
  }

  double _calculateConfidence(List<int> cycleLengths) {
    if (cycleLengths.length < 2) {
      return 0.45;
    }

    final double stdDev = standardDeviation(cycleLengths);
    final double normalized = (1 - (stdDev / 10)).clamp(0.35, 0.98);
    return normalized.toDouble();
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

extension on double {
  double sqrt() {
    if (this <= 0) {
      return 0;
    }

    double guess = this / 2;
    for (int i = 0; i < 12; i++) {
      guess = (guess + this / guess) / 2;
    }
    return guess;
  }
}
