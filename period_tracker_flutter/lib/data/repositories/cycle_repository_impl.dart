import '../../features/cycle/domain/entities/cycle_entry.dart';
import '../../features/cycle/domain/repositories/cycle_repository.dart';
import '../datasources/local/cycle_local_data_source.dart';
import '../models/cycle_model.dart';

class CycleRepositoryImpl implements CycleRepository {
  const CycleRepositoryImpl(this._localDataSource);

  final CycleLocalDataSource _localDataSource;

  @override
  Future<List<CycleEntry>> getCycles() {
    return _localDataSource.getCycles();
  }

  @override
  Future<void> addCycle(CycleEntry cycle) {
    return _localDataSource.upsertCycle(CycleModel.fromEntity(cycle));
  }

  @override
  Future<void> deleteCycle(String id) {
    return _localDataSource.deleteCycle(id);
  }
}
