class AssignmentDraft {
  const AssignmentDraft({
    this.id,
    required this.title,
    required this.subject,
    required this.dueDateTime,
    required this.notes,
  });

  final int? id;
  final String title;
  final String subject;
  final DateTime dueDateTime;
  final String notes;

  AssignmentDraft copyWith({
    int? id,
    String? title,
    String? subject,
    DateTime? dueDateTime,
    String? notes,
  }) {
    return AssignmentDraft(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      notes: notes ?? this.notes,
    );
  }
}
