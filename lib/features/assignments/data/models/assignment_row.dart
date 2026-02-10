class AssignmentRow {
  const AssignmentRow({
    this.id,
    required this.title,
    required this.subject,
    required this.dueAt,
    required this.notes,
  });

  //Fields ทั้งหมด
  final int? id;
  final String title;
  final String subject;
  final DateTime dueAt;
  final String notes;

  Map<String, Object?> toMap() { //แปลง Object → Database
    return <String, Object?> {
      'id': id,
      'title': title,
      'subject': subject,
      'due_at': dueAt.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  factory AssignmentRow.fromMap(Map<String, Object?> map){ //Database → Object
    return AssignmentRow(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '', //?? '' ถ้า null → ใช้ค่าว่างแทน
      subject: map['subject'] as String? ?? '', 
      dueAt: DateTime.fromMillisecondsSinceEpoch((map['due_at'] as int?) ?? 0), 
      notes: map['subject'] as String? ?? '', 
    );
  }
}
