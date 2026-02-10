class AssignmentRow {
  const AssignmentRow({
    this.id,
    required this.title,
    required this.subject,
    required this.subjectId,
    required this.dueAt,
    required this.notes,
    required this.status,
    this.completedAt,
  });

  final String? id;
  final String title;
  final String subject;
  final String? subjectId; // new FK
  final DateTime dueAt;
  final String notes;
  final String status; // to_do, in_progress, late, completed
  final DateTime? completedAt;

  Map<String, dynamic> toInsertMap({required String userId}) {
    return <String, dynamic>{
      'user_id': userId,
      'title': title,
      'subject': subject,
      'due_at': dueAt.toUtc().toIso8601String(),
      'notes': notes,
      'status': status,
      'completed_at': completedAt?.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return <String, dynamic>{
      'title': title,
      'subject': subject,
      'due_at': dueAt.toUtc().toIso8601String(),
      'notes': notes,
      'status': status,
      'completed_at': completedAt?.toUtc().toIso8601String(),
    };
  }

  factory AssignmentRow.fromMap(Map<String, dynamic> map) {
    return AssignmentRow(
      id: map['id'] as String?,
      title: map['title'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      dueAt: DateTime.parse(map['due_at'] as String).toLocal(),
      notes: map['notes'] as String? ?? '',
      status: map['status'] as String? ?? '',
      completedAt: map['completed_at'] == null
        ? null
        : DateTime.parse(map['completed_at'] as String).toLocal(),
    );
  }
}
