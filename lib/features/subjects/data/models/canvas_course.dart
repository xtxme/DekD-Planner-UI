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

  String get importDescription =>
      'Imported from Canvas (course_id: $id)'; //คืนค่าเป็นข้อความ (String) ที่บอกว่า "นำเข้าจาก Canvas" พร้อมกับระบุ id ของคอร์สนั้นๆ

  factory CanvasCourse.fromMap(Map<String, dynamic> map) => CanvasCourse(
    //ข้อมูลที่ส่งมาจาก Server (API) อยู่ในรูปแบบ JSON (ซึ่ง Dart มองเป็น Map)
    id: map['id'] as int? ?? 0,
    name: map['name'] as String? ?? '',
    courseCode: map['course_code'] as String? ?? '',
    sisCourseId: map['sis_course_id'] as String? ?? '',
    teacherName: _extractTeacherName(map),
  );

  static String _extractTeacherName(Map<String, dynamic> map) {
    final rawTeachers = map['teachers'];
    if (rawTeachers is List) {
      for (final teacher in rawTeachers) {
        if (teacher is! Map) continue;
        final teacherMap = Map<String, dynamic>.from(teacher);

        final displayName = teacherMap['display_name'];
        if (displayName is String && displayName.trim().isNotEmpty) {
          return displayName.trim();
        }

        final name = teacherMap['name'];
        if (name is String && name.trim().isNotEmpty) {
          return name.trim();
        }

        final sortableName = teacherMap['sortable_name'];
        if (sortableName is String && sortableName.trim().isNotEmpty) {
          return sortableName.trim();
        }
      }
    }
    return '';
  }
}
