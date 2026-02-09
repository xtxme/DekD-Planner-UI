class AssignmentDraft {
  const AssignmentDraft({
    required this.title,
    required this.subject,
    required this.dueDateTime,
    required this.notes,
  });

  final String title;
  final String subject;
  final DateTime dueDateTime;
  final String notes;
}
