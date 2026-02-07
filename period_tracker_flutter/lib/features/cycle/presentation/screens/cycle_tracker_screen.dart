import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/cycle_controller.dart';

class CycleTrackerScreen extends ConsumerStatefulWidget {
  const CycleTrackerScreen({super.key});

  @override
  ConsumerState<CycleTrackerScreen> createState() => _CycleTrackerScreenState();
}

class _CycleTrackerScreenState extends ConsumerState<CycleTrackerScreen> {
  final TextEditingController _notesController = TextEditingController();
  ProviderSubscription<CycleState>? _cycleSubscription;

  @override
  void initState() {
    super.initState();
    _cycleSubscription = ref.listenManual<CycleState>(cycleControllerProvider, (
      CycleState? previous,
      CycleState next,
    ) {
      final String? message = next.errorMessage;
      if (message != null && message != previous?.errorMessage && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
  }

  @override
  void dispose() {
    _cycleSubscription?.close();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _onAddCyclePressed() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 4)),
        end: now,
      ),
    );

    if (dateRange == null || !mounted) {
      return;
    }

    final String? notes = await _showNotesDialog();
    if (!mounted) {
      return;
    }

    await ref
        .read(cycleControllerProvider.notifier)
        .addCycle(
          startDate: dateRange.start,
          endDate: dateRange.end,
          notes: notes,
        );
  }

  Future<String?> _showNotesDialog() async {
    _notesController.clear();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Optional note'),
          content: TextField(
            controller: _notesController,
            maxLines: 2,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Symptoms, mood, reminders...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_notesController.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final CycleState state = ref.watch(cycleControllerProvider);
    final DateFormat dateFormat = DateFormat('MMM d, yyyy');

    return Stack(
      children: <Widget>[
        RefreshIndicator(
          onRefresh: () =>
              ref.read(cycleControllerProvider.notifier).loadCycles(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: <Widget>[
              if (state.prediction != null) ...<Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Prediction',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        _PredictionLine(
                          label: 'Next period start',
                          value: dateFormat.format(
                            state.prediction!.predictedStartDate,
                          ),
                        ),
                        _PredictionLine(
                          label: 'Next period end',
                          value: dateFormat.format(
                            state.prediction!.predictedEndDate,
                          ),
                        ),
                        _PredictionLine(
                          label: 'Ovulation day',
                          value: dateFormat.format(
                            state.prediction!.ovulationDate,
                          ),
                        ),
                        _PredictionLine(
                          label: 'Fertile window',
                          value:
                              '${dateFormat.format(state.prediction!.fertileWindowStart)} - ${dateFormat.format(state.prediction!.fertileWindowEnd)}',
                        ),
                        _PredictionLine(
                          label: 'Weighted cycle',
                          value:
                              '${state.prediction!.weightedAverageCycleLength.toStringAsFixed(1)} d',
                        ),
                        _PredictionLine(
                          label: 'Confidence',
                          value:
                              '${(state.prediction!.confidence * 100).toStringAsFixed(0)}%',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Cycle History',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (state.entries.isEmpty)
                        const Text(
                          'No cycle entries yet. Add your first entry to begin tracking.',
                        )
                      else
                        ...state.entries.map((entry) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              '${dateFormat.format(entry.startDate)} - ${dateFormat.format(entry.endDate)}',
                            ),
                            subtitle: Text(
                              'Length: ${entry.periodLengthDays} days',
                            ),
                            trailing: IconButton(
                              onPressed: () => ref
                                  .read(cycleControllerProvider.notifier)
                                  .deleteCycle(entry.id),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              if (state.isLoading) ...<Widget>[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _onAddCyclePressed,
            icon: const Icon(Icons.add),
            label: const Text('Add Cycle'),
          ),
        ),
      ],
    );
  }
}

class _PredictionLine extends StatelessWidget {
  const _PredictionLine({required this.label, required this.value});

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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
