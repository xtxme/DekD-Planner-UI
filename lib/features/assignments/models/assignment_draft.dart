class AssignmentDraft {
  const AssignmentDraft({
    this.id,
    required this.title,
    required this.subject,
    required this.dueDateTime,
    required this.notes,
  });

  final String? id;
  final String title;
  final String subject;
  final DateTime dueDateTime;
  final String notes;

  AssignmentDraft copyWith({
    String? id,
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
