//แบบแปลนสำหรับสร้างกล่องเก็บข้อมูลวิชาเรียน

class CanvasCourse {
  const CanvasCourse({
    required this.id,
    required this.name,
    required this.courseCode,
    required this.sisCourseId,
  });

  final int id;
  final String name;
  final String courseCode;
  final String sisCourseId;

  String get importDescription => 'Imported from Canvas (course_id: $id)'; //คืนค่าเป็นข้อความ (String) ที่บอกว่า "นำเข้าจาก Canvas" พร้อมกับระบุ id ของคอร์สนั้นๆ

  factory CanvasCourse.fromMap(Map<String, dynamic> map) => CanvasCourse( //ข้อมูลที่ส่งมาจาก Server (API) อยู่ในรูปแบบ JSON (ซึ่ง Dart มองเป็น Map)
    id: map['id'] as int? ?? 0,
    name: map['name'] as String? ?? '',
    courseCode: map['course_code'] as String? ?? '',
    sisCourseId: map['sis_course_id'] as String? ?? '',
  );
}
