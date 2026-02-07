import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/cycle_length_chart.dart';
import '../controllers/cycle_controller.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CycleState state = ref.watch(cycleControllerProvider);
    final analytics = state.analytics;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Trend Graph',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: CycleLengthChart(
                    cycleLengths: analytics.cycleLengths,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Cycle Statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                _MetricRow(
                  title: 'Average cycle length',
                  value:
                      '${analytics.averageCycleLength.toStringAsFixed(1)} days',
                ),
                _MetricRow(
                  title: 'Weighted average cycle',
                  value:
                      '${analytics.weightedAverageCycleLength.toStringAsFixed(1)} days',
                ),
                _MetricRow(
                  title: 'Standard deviation',
                  value: analytics.standardDeviation.toStringAsFixed(2),
                ),
                _MetricRow(
                  title: 'Cycle samples',
                  value: analytics.cycleLengths.length.toString(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Irregularity Detection',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Icon(
                      analytics.isIrregular
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle,
                      color: analytics.isIrregular
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        analytics.isIrregular
                            ? 'Detected irregular cycle pattern (std dev >= 3.0).'
                            : 'Cycle pattern is within stable range.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
