import '../../features/cycle/domain/entities/cycle_entry.dart';

class CycleModel extends CycleEntry {
  const CycleModel({
    required super.id,
    required super.startDate,
    required super.endDate,
    super.notes,
  });

  factory CycleModel.fromEntity(CycleEntry entry) {
    return CycleModel(
      id: entry.id,
      startDate: entry.startDate,
      endDate: entry.endDate,
      notes: entry.notes,
    );
  }

  factory CycleModel.fromMap(Map<String, dynamic> map) {
    return CycleModel(
      id: map['id'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'notes': notes,
    };
  }
}
