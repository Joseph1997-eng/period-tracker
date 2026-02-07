class CycleEntry {
  CycleEntry({
    required this.id,
    required this.startDate,
    required this.endDate,
    this.notes,
  }) : assert(
         !endDate.isBefore(startDate),
         'endDate must be on/after startDate',
       );

  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;

  int get periodLengthDays => endDate.difference(startDate).inDays + 1;

  CycleEntry copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) {
    return CycleEntry(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
    );
  }
}
