import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CycleLengthChart extends StatelessWidget {
  const CycleLengthChart({
    super.key,
    required this.cycleLengths,
    required this.color,
  });

  final List<int> cycleLengths;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (cycleLengths.length < 2) {
      return const Center(
        child: Text('Add at least 2 cycles to visualize analytics.'),
      );
    }

    final List<FlSpot> spots = cycleLengths
        .asMap()
        .entries
        .map(
          (MapEntry<int, int> e) =>
              FlSpot(e.key.toDouble(), e.value.toDouble()),
        )
        .toList(growable: false);

    final int minY = cycleLengths.reduce((int a, int b) => a < b ? a : b) - 2;
    final int maxY = cycleLengths.reduce((int a, int b) => a > b ? a : b) + 2;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (cycleLengths.length - 1).toDouble(),
        minY: minY.toDouble(),
        maxY: maxY.toDouble(),
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 36,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '#${value.toInt() + 1}',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
        ),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter:
                  (
                    FlSpot spot,
                    double xPercentage,
                    LineChartBarData barData,
                    int index, {
                    double? size,
                  }) {
                    return FlDotCirclePainter(
                      radius: 3.5,
                      color: color,
                      strokeWidth: 1,
                      strokeColor: Theme.of(context).scaffoldBackgroundColor,
                    );
                  },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: <Color>[
                  color.withValues(alpha: 0.25),
                  color.withValues(alpha: 0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}
