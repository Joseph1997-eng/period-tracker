class AnalyticsSummary {
  const AnalyticsSummary({
    required this.cycleLengths,
    required this.averageCycleLength,
    required this.weightedAverageCycleLength,
    required this.standardDeviation,
    required this.isIrregular,
  });

  final List<int> cycleLengths;
  final double averageCycleLength;
  final double weightedAverageCycleLength;
  final double standardDeviation;
  final bool isIrregular;

  static const AnalyticsSummary empty = AnalyticsSummary(
    cycleLengths: <int>[],
    averageCycleLength: 28,
    weightedAverageCycleLength: 28,
    standardDeviation: 0,
    isIrregular: false,
  );
}
