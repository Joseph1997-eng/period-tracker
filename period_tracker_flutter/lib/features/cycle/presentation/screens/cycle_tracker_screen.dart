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

  @override
  void dispose() {
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
              hintText: 'Symptoms, mood, reminders... ',
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
    ref.listen<CycleState>(cycleControllerProvider, (
      CycleState? previous,
      CycleState next,
    ) {
      final String? message = next.errorMessage;
      if (message != null && message != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });

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
                          'Next Prediction',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Period starts: ${dateFormat.format(state.prediction!.predictedStartDate)}',
                        ),
                        Text(
                          'Period ends: ${dateFormat.format(state.prediction!.predictedEndDate)}',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Weighted cycle length: ${state.prediction!.weightedAverageCycleLength.toStringAsFixed(1)} days',
                        ),
                        Text(
                          'Confidence: ${(state.prediction!.confidence * 100).toStringAsFixed(0)}%',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'History',
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
