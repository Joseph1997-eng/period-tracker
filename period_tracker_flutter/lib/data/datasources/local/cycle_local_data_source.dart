import 'package:hive/hive.dart';

import '../../models/cycle_model.dart';

class CycleLocalDataSource {
  const CycleLocalDataSource(this._box);

  final Box<dynamic> _box;

  Future<List<CycleModel>> getCycles() async {
    final List<CycleModel> cycles = <CycleModel>[];

    for (final dynamic raw in _box.values) {
      if (raw is Map) {
        final Map<String, dynamic> typedMap = raw.map<String, dynamic>(
          (dynamic key, dynamic value) =>
              MapEntry<String, dynamic>(key.toString(), value),
        );
        cycles.add(CycleModel.fromMap(typedMap));
      }
    }

    cycles.sort(
      (CycleModel a, CycleModel b) => b.startDate.compareTo(a.startDate),
    );
    return cycles;
  }

  Future<void> upsertCycle(CycleModel cycle) async {
    await _box.put(cycle.id, cycle.toMap());
  }

  Future<void> deleteCycle(String id) async {
    await _box.delete(id);
  }
}
