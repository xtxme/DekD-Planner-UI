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

/// Response จาก Edge Function ที่รวมข้อมูล user และ assignments
class CanvasAssignmentsResponse {
  const CanvasAssignmentsResponse({
    required this.user,
    required this.assignments,
  });

  final CanvasUserResponse user;
  final List<CanvasAssignment> assignments;

  factory CanvasAssignmentsResponse.fromMap(Map<String, dynamic> map) {
    final rawUser = map['user'];
    final user = rawUser is Map<String, dynamic>
        ? CanvasUserResponse.fromMap(rawUser)
        : const CanvasUserResponse(id: '', email: '');

    final rawAssignments = map['assignments'];
    final assignments = rawAssignments is List
        ? rawAssignments
              .whereType<Map>()
              .map(
                (item) =>
                    CanvasAssignment.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <CanvasAssignment>[];

    return CanvasAssignmentsResponse(user: user, assignments: assignments);
  }
}

class CanvasUserResponse {
  const CanvasUserResponse({required this.id, required this.email});

  final String id;
  final String email;

  factory CanvasUserResponse.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'];
    final id = rawId is String ? rawId : '';

    final rawEmail = map['email'];
    final email = rawEmail is String ? rawEmail : '';

    return CanvasUserResponse(id: id, email: email);
  }
}
