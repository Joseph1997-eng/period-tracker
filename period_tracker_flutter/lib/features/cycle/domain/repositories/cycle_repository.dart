import '../entities/cycle_entry.dart';

abstract class CycleRepository {
  Future<List<CycleEntry>> getCycles();
  Future<void> addCycle(CycleEntry cycle);
  Future<void> deleteCycle(String id);
}
