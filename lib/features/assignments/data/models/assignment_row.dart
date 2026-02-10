class AssignmentRow {
  const AssignmentRow({
    this.id,
    required this.title,
    required this.subject,
    required this.dueAt,
    required this.notes,
  });

  final String? id;
  final String title;
  final String subject;
  final DateTime dueAt;
  final String notes;

  Map<String, dynamic> toInsertMap({required String userId}) {
    return <String, dynamic>{
      'user_id': userId,
      'title': title,
      'subject': subject,
      'due_at': dueAt.toUtc().toIso8601String(),
      'notes': notes,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return <String, dynamic>{
      'title': title,
      'subject': subject,
      'due_at': dueAt.toUtc().toIso8601String(),
      'notes': notes,
    };
  }

  factory AssignmentRow.fromMap(Map<String, dynamic> map) {
    return AssignmentRow(
      id: map['id'] as String?,
      title: map['title'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      dueAt: DateTime.parse(map['due_at'] as String).toLocal(),
      notes: map['notes'] as String? ?? '',
    );
  }
}
