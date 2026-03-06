import 'package:my_first_app/features/subjects/data/models/canvas_course.dart';
import 'package:my_first_app/features/subjects/data/models/subject_row.dart';

class SubjectDetailInfo {
  const SubjectDetailInfo({
    required this.teacherInfo,
    required this.description,
  });

  final String teacherInfo;
  final String description;
}

final RegExp _courseIdRegex = RegExp(
  r'course_id:\s*(\d+)',
  caseSensitive: false,
);
final RegExp _instructorRegex = RegExp(
  r'Instructor:\s*(.+)$',
  caseSensitive: false,
);

SubjectDetailInfo resolveSubjectDetailInfo({
  required SubjectRow subject,
  required List<CanvasCourse> canvasCourses,
}) {
  final rawDescription = subject.description.trim();
  final isCanvasImport = rawDescription.toLowerCase().startsWith(
    'imported from canvas',
  );

  final courseIdMatch = _courseIdRegex.firstMatch(rawDescription);
  final courseId = int.tryParse(courseIdMatch?.group(1) ?? '');

  String teacherName = '';

  if (courseId != null) {
    final matchedCourse = canvasCourses.where(
      (course) => course.id == courseId,
    );
    if (matchedCourse.isNotEmpty) {
      teacherName = matchedCourse.first.teacherName.trim();
    }
  }

  if (teacherName.isEmpty) {
    final instructorMatch = _instructorRegex.firstMatch(rawDescription);
    teacherName = instructorMatch?.group(1)?.trim() ?? '';
  }

  final teacherInfo = teacherName.isNotEmpty ? 'Instructor: $teacherName' : '';

  if (isCanvasImport && teacherInfo.isNotEmpty) {
    return SubjectDetailInfo(teacherInfo: teacherInfo, description: '');
  }

  return SubjectDetailInfo(
    teacherInfo: teacherInfo,
    description: rawDescription,
  );
}
