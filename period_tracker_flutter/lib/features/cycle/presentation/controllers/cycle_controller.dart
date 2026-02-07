import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/app_providers.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/cycle_entry.dart';
import '../../domain/entities/cycle_prediction.dart';
import '../../domain/repositories/cycle_repository.dart';
import '../../domain/services/cycle_analytics_engine.dart';

class CycleState {
  const CycleState({
    required this.entries,
    required this.analytics,
    required this.prediction,
    required this.isLoading,
    required this.errorMessage,
  });

  final List<CycleEntry> entries;
  final AnalyticsSummary analytics;
  final CyclePrediction? prediction;
  final bool isLoading;
  final String? errorMessage;

  static const CycleState initial = CycleState(
    entries: <CycleEntry>[],
    analytics: AnalyticsSummary.empty,
    prediction: null,
    isLoading: false,
    errorMessage: null,
  );

  CycleState copyWith({
    List<CycleEntry>? entries,
    AnalyticsSummary? analytics,
    CyclePrediction? prediction,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool clearPrediction = false,
  }) {
    return CycleState(
      entries: entries ?? this.entries,
      analytics: analytics ?? this.analytics,
      prediction: clearPrediction ? null : (prediction ?? this.prediction),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class CycleController extends StateNotifier<CycleState> {
  CycleController({
    required CycleRepository repository,
    required CycleAnalyticsEngine analyticsEngine,
  }) : _repository = repository,
       _analyticsEngine = analyticsEngine,
       _uuid = const Uuid(),
       super(CycleState.initial) {
    loadCycles();
  }

  final CycleRepository _repository;
  final CycleAnalyticsEngine _analyticsEngine;
  final Uuid _uuid;

  Future<void> loadCycles() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final List<CycleEntry> entries = await _repository.getCycles();
      final AnalyticsSummary analytics = _analyticsEngine.buildAnalytics(
        entries,
      );
      final CyclePrediction? prediction = _analyticsEngine.predictNextCycle(
        entries,
      );

      state = state.copyWith(
        entries: entries,
        analytics: analytics,
        prediction: prediction,
        isLoading: false,
        clearErrorMessage: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load cycle data. Please try again.',
      );
    }
  }

  Future<void> addCycle({
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    final String? trimmedNotes = notes?.trim();

    final CycleEntry entry = CycleEntry(
      id: _uuid.v4(),
      startDate: _dateOnly(startDate),
      endDate: _dateOnly(endDate),
      notes: (trimmedNotes == null || trimmedNotes.isEmpty)
          ? null
          : trimmedNotes,
    );

    try {
      await _repository.addCycle(entry);
      await loadCycles();
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to save cycle entry.');
    }
  }

  Future<void> deleteCycle(String id) async {
    try {
      await _repository.deleteCycle(id);
      await loadCycles();
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to delete cycle entry.');
    }
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

final StateNotifierProvider<CycleController, CycleState>
cycleControllerProvider = StateNotifierProvider<CycleController, CycleState>(
  (Ref ref) => CycleController(
    repository: ref.watch(cycleRepositoryProvider),
    analyticsEngine: ref.watch(cycleAnalyticsEngineProvider),
  ),
);
