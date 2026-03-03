class CanvasAssignment {
  const CanvasAssignment({
    required this.id,
    required this.name,
    required this.dueAt,
    required this.courseId,
    required this.courseName,
    required this.description,
  });

  final int id;
  final String name;
  final DateTime? dueAt;
  final int? courseId;
  final String courseName;
  final String description;

  factory CanvasAssignment.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'];
    final id = rawId is int ? rawId : 0;

    final rawName = map['name'];
    final name = rawName is String ? rawName.trim() : '';

    final rawDueAt = map['due_at'];
    final dueAt = rawDueAt is String && rawDueAt.isNotEmpty
        ? DateTime.parse(rawDueAt).toLocal()
        : null;

    final rawCourseId = map['course_id'];
    final courseId = rawCourseId is int ? rawCourseId : null;

    final rawCourseName = map['course_name'];
    final courseName = rawCourseName is String ? rawCourseName.trim() : '';

    final rawDescription = map['description'];
    final description = rawDescription is String ? rawDescription.trim() : '';

    return CanvasAssignment(
      id: id,
      name: name,
      dueAt: dueAt,
      courseId: courseId,
      courseName: courseName,
      description: description,
    );
  }
}
