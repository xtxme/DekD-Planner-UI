//แบบแปลนสำหรับสร้างกล่องเก็บข้อมูลวิชาเรียน

class CanvasCourse {
  const CanvasCourse({
    required this.id,
    required this.name,
    required this.courseCode,
    required this.sisCourseId,
    required this.teacherName,
  });

  final int id;
  final String name;
  final String courseCode;
  final String sisCourseId;
  final String teacherName;

  String get importDescription {
    final trimmedTeacherName = teacherName.trim();
    final baseDescription = 'Imported from Canvas (course_id: $id)';
    if (trimmedTeacherName.isEmpty) {
      return baseDescription;
    }
    return '$baseDescription | Instructor: $trimmedTeacherName';
  } //คืนค่าเป็นข้อความ (String) ที่บอกว่า "นำเข้าจาก Canvas" พร้อมกับระบุ id ของคอร์สนั้นๆ

  factory CanvasCourse.fromMap(Map<String, dynamic> map) => CanvasCourse(
    //ข้อมูลที่ส่งมาจาก Server (API) อยู่ในรูปแบบ JSON (ซึ่ง Dart มองเป็น Map)
    id: map['id'] as int? ?? 0,
    name: map['name'] as String? ?? '',
    courseCode: map['course_code'] as String? ?? '',
    sisCourseId: map['sis_course_id'] as String? ?? '',
    teacherName: _extractTeacherName(map),
  );

  static String _extractTeacherName(Map<String, dynamic> map) {
    final teachersFromList = _extractFirstTeacherNameFromList(map['teachers']);
    if (teachersFromList.isNotEmpty) return teachersFromList;

    final instructorsFromList = _extractFirstTeacherNameFromList(
      map['instructors'],
    );
    if (instructorsFromList.isNotEmpty) return instructorsFromList;

    final teacher = map['teacher'];
    if (teacher is Map) {
      final name = _extractNameFromMap(Map<String, dynamic>.from(teacher));
      if (name.isNotEmpty) return name;
    }
    if (teacher is String && teacher.trim().isNotEmpty) {
      return teacher.trim();
    }

    return '';
  }

  static String _extractFirstTeacherNameFromList(dynamic rawPeople) {
    if (rawPeople is! List) return '';

    for (final person in rawPeople) {
      if (person is! Map) continue;
      final name = _extractNameFromMap(Map<String, dynamic>.from(person));
      if (name.isNotEmpty) return name;
    }

    return '';
  }

  static String _extractNameFromMap(Map<String, dynamic> personMap) {
    final displayName = personMap['display_name'];
    if (displayName is String && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    final name = personMap['name'];
    if (name is String && name.trim().isNotEmpty) {
      return name.trim();
    }

    final sortableName = personMap['sortable_name'];
    if (sortableName is String && sortableName.trim().isNotEmpty) {
      return sortableName.trim();
    }

    final shortName = personMap['short_name'];
    if (shortName is String && shortName.trim().isNotEmpty) {
      return shortName.trim();
    }

    return '';
  }
}
