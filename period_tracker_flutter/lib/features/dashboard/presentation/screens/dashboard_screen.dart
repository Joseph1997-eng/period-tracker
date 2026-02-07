import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/cycle_length_chart.dart';
import '../../../cycle/presentation/controllers/cycle_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CycleState state = ref.watch(cycleControllerProvider);
    final DateFormat dateFormat = DateFormat('MMM d, yyyy');
    final ThemeData theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => ref.read(cycleControllerProvider.notifier).loadCycles(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: state.prediction == null
                ? const Text(
                    'Add at least one cycle to generate predictions.',
                    style: TextStyle(color: Colors.white),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Next Period Forecast',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        dateFormat.format(state.prediction!.predictedStartDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Confidence: ${(state.prediction!.confidence * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatCard(
                  title: 'Weighted Avg',
                  value:
                      '${state.analytics.weightedAverageCycleLength.toStringAsFixed(1)} d',
                  icon: Icons.stacked_line_chart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Std Dev',
                  value: state.analytics.standardDeviation.toStringAsFixed(2),
                  icon: Icons.timeline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Icon(
                    state.analytics.isIrregular
                        ? Icons.warning_amber_rounded
                        : Icons.verified_rounded,
                    color: state.analytics.isIrregular
                        ? Colors.orange
                        : Colors.green,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.analytics.isIrregular
                          ? 'Irregularity detected: cycle variation is elevated.'
                          : 'Cycle appears stable based on standard deviation.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (state.prediction != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Ovulation Window',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    _InfoLine(
                      label: 'Ovulation',
                      value: dateFormat.format(state.prediction!.ovulationDate),
                    ),
                    _InfoLine(
                      label: 'Fertile start',
                      value: dateFormat.format(
                        state.prediction!.fertileWindowStart,
                      ),
                    ),
                    _InfoLine(
                      label: 'Fertile end',
                      value: dateFormat.format(
                        state.prediction!.fertileWindowEnd,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Cycle Length Trend',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220,
                    child: CycleLengthChart(
                      cycleLengths: state.analytics.cycleLengths,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 20),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
