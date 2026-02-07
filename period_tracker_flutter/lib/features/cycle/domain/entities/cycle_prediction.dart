class CyclePrediction {
  const CyclePrediction({
    required this.predictedStartDate,
    required this.predictedEndDate,
    required this.ovulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.weightedAverageCycleLength,
    required this.confidence,
  });

  final DateTime predictedStartDate;
  final DateTime predictedEndDate;
  final DateTime ovulationDate;
  final DateTime fertileWindowStart;
  final DateTime fertileWindowEnd;
  final double weightedAverageCycleLength;
  final double confidence;
}
