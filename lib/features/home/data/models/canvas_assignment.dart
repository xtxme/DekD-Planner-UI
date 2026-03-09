int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

String _toText(dynamic value) {
  return value is String ? value.trim() : '';
}

bool? _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

String _firstNonEmptyText(Iterable<dynamic> values) {
  for (final value in values) {
    final text = _toText(value);
    if (text.isNotEmpty) return text;
  }
  return '';
}

class CanvasAssignment {
  const CanvasAssignment({
    required this.id,
    required this.name,
    required this.dueAt,
    required this.courseId,
    required this.courseName,
    required this.description,
    this.isCompleted = false,
    this.submissionState = '',
  });

  final int id;
  final String name;
  final DateTime? dueAt;
  final int? courseId;
  final String courseName;
  final String description;
  final bool isCompleted;
  final String submissionState;

  factory CanvasAssignment.fromMap(Map<String, dynamic> map) {
    final assignment = map['assignment'] is Map
        ? Map<String, dynamic>.from(map['assignment'] as Map)
        : const <String, dynamic>{};

    final course = map['course'] is Map
        ? Map<String, dynamic>.from(map['course'] as Map)
        : const <String, dynamic>{};

    final id = _toInt(map['id']) ?? _toInt(assignment['id']) ?? 0;

    final name = _firstNonEmptyText([map['name'], assignment['name']]);

    final rawDueAt = _firstNonEmptyText([
      map['due_at'],
      map['dueAt'],
      assignment['due_at'],
      assignment['dueAt'],
    ]);
    final dueAt = rawDueAt.isNotEmpty
        ? DateTime.tryParse(rawDueAt)?.toLocal()
        : null;

    final courseId =
        _toInt(map['course_id']) ??
        _toInt(map['courseId']) ??
        _toInt(course['id']) ??
        _toInt(course['course_id']) ??
        _toInt(assignment['course_id']) ??
        _toInt(assignment['courseId']);

    final courseName = _firstNonEmptyText([
      map['course_name'],
      map['courseName'],
      map['context_name'],
      map['contextName'],
      course['name'],
      course['course_name'],
      assignment['course_name'],
      assignment['courseName'],
    ]);

    final description = _firstNonEmptyText([
      map['description'],
      assignment['description'],
    ]);

    final submissionState = _firstNonEmptyText([
      map['submission_state'],
      map['submissionState'],
      map['workflow_state'],
      map['workflowState'],
      assignment['submission_state'],
      assignment['submissionState'],
      assignment['workflow_state'],
      assignment['workflowState'],
    ]).toLowerCase();

    final completedSignal =
        _toBool(map['is_completed']) ??
        _toBool(map['isCompleted']) ??
        _toBool(map['completed']) ??
        _toBool(assignment['is_completed']) ??
        _toBool(assignment['isCompleted']) ??
        _toBool(assignment['completed']) ??
        _toBool(assignment['has_submitted_submissions']) ??
        false;

    final isCompletedFromState =
        submissionState == 'graded' ||
        submissionState == 'submitted' ||
        submissionState == 'complete' ||
        submissionState == 'completed';

    return CanvasAssignment(
      id: id,
      name: name,
      dueAt: dueAt,
      courseId: courseId,
      courseName: courseName,
      description: description,
      isCompleted: completedSignal || isCompletedFromState,
      submissionState: submissionState,
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

/// ✅ Assignment Details จาก Canvas API - มากขึ้น (รวม notes/instructions ละเอียด)
class CanvasAssignmentDetails {
  const CanvasAssignmentDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.fullDescription,
    required this.pointsPossible,
    required this.submissionTypes,
    required this.rubric,
    this.dueAt,
    required this.courseId,
  });

  final int id;
  final String name;
  final String description;
  final String fullDescription; // ✅ HTML ของละเอียด (notes/instructions)
  final int? pointsPossible;
  final List<dynamic> submissionTypes;
  final dynamic rubric;
  final DateTime? dueAt;
  final int courseId;

  factory CanvasAssignmentDetails.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'];
    final id = rawId is int ? rawId : 0;

    final rawName = map['name'];
    final name = rawName is String ? rawName.trim() : '';

    final rawDescription = map['description'];
    final description = rawDescription is String ? rawDescription.trim() : '';
    final fullDescription = description; // ✅ ใช้เดียวกับ description

    final rawPointsPossible = map['points_possible'];
    final pointsPossible = rawPointsPossible is int ? rawPointsPossible : null;

    final rawSubmissionTypes = map['submission_types'];
    final submissionTypes = rawSubmissionTypes is List
        ? rawSubmissionTypes
        : [];

    final rubric = map['rubric'];

    final rawDueAt = map['due_at'];
    final dueAt = rawDueAt is String && rawDueAt.isNotEmpty
        ? DateTime.parse(rawDueAt).toLocal()
        : DateTime.tryParse(rawDueAt ?? '');

    final rawCourseId = map['course_id'];
    final courseId = rawCourseId is int ? rawCourseId : 0;

    return CanvasAssignmentDetails(
      id: id,
      name: name,
      description: description,
      fullDescription: fullDescription,
      pointsPossible: pointsPossible,
      submissionTypes: submissionTypes,
      rubric: rubric,
      dueAt: dueAt,
      courseId: courseId,
    );
  }
}
